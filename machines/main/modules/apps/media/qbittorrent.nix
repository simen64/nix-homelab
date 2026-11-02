{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  webuiPort = 8090; # 8080 is taken by seafile
  vpn = "warp";
in {
  imports = [inputs.vpn-confinement.nixosModules.default];

  # Cloudflare WARP config generated with `wgcf register && wgcf generate`
  clan.core.vars.generators.warp = {
    prompts.wgcf-profile = {
      description = "Contents of wgcf-profile.conf";
      type = "multiline-hidden";
    };
    files."wg0.conf" = {
      secret = true;
    };
    script = ''
      if ! grep -q '^\[Interface\]' $prompts/wgcf-profile || ! grep -q '^Endpoint' $prompts/wgcf-profile; then
        echo "Input doesn't look like a wgcf-profile.conf (missing [Interface] or Endpoint line)" >&2
        exit 1
      fi

      # The namespace can't resolve DNS before the tunnel is up, so use the endpoint IP directly
      sed 's/engage\.cloudflareclient\.com/162.159.192.1/' $prompts/wgcf-profile > $out/wg0.conf

      # VPN-Confinement requires a DNS line, newer wgcf versions leave it out
      if ! grep -qi '^DNS' $out/wg0.conf; then
        sed -i '/^\[Interface\]/a DNS = 1.1.1.1, 1.0.0.1' $out/wg0.conf
      fi
    '';
    runtimeInputs = [pkgs.gnused pkgs.gnugrep];
  };

  # Network namespace where all traffic goes through WARP, nothing leaks if the tunnel is down
  vpnNamespaces.${vpn} = {
    enable = true;
    wireguardConfigFile = config.clan.core.vars.generators.warp.files."wg0.conf".path;
    # Netbird peers can reach the web UI through the port mapping
    accessibleFrom = ["100.64.0.0/10"];
    portMappings = [
      {
        from = webuiPort;
        to = webuiPort;
      }
    ];
  };

  # main's ISP drops all ICMP, so VPN-Confinement's ping check on the endpoint always fails.
  # WireGuard runs over UDP, so check for a route to the endpoint instead.
  systemd.services.${vpn}.serviceConfig.ExecStart = let
    vpnUp = import "${inputs.vpn-confinement}/modules/vpn-up.nix" {
      inherit pkgs lib;
      optionalIPv6String = lib.optionalString config.networking.enableIPv6;
    };
    original = vpnUp vpn config.vpnNamespaces.${vpn};
    patched = pkgs.runCommand "${vpn}-up" {} ''
      grep -q 'ping -c 1 "$EndpointIP"' ${original}/bin/${vpn}-up
      mkdir -p $out/bin
      sed 's/ping -c 1 "$EndpointIP"/ip route get "$EndpointIP"/' ${original}/bin/${vpn}-up > $out/bin/${vpn}-up
      chmod +x $out/bin/${vpn}-up
    '';
  in
    lib.mkForce "${patched}/bin/${vpn}-up";

  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    vpnNamespace = vpn;
  };

  # Behind WARP's NAT: no inbound port, qBittorrent only makes outbound connections to peers.
  services.qbittorrent = {
    enable = true;
    group = "media";
    inherit webuiPort;

    # Rewritten on every service start, so change settings here instead of in the web UI.
    serverConfig = {
      LegalNotice.Accepted = true;

      BitTorrent = {
        # Never download executables, scripts or archives, fake movies are almost always one of these
        ExcludedFileNamesEnabled = true;

        Session = {
          ExcludedFileNames = lib.concatStringsSep ", " [
            "*.exe"
            "*.scr"
            "*.com"
            "*.bat"
            "*.cmd"
            "*.msi"
            "*.pif"
            "*.lnk"
            "*.url"
            "*.vbs"
            "*.vbe"
            "*.js"
            "*.jse"
            "*.wsf"
            "*.hta"
            "*.ps1"
            "*.jar"
            "*.apk"
            "*.dll"
            "*.sh"
            "*.zip"
            "*.zipx"
            "*.rar"
            "*.7z"
            "*.cab"
          ];

          # Only ever use the WARP interface
          Interface = "${vpn}0";
          InterfaceName = "${vpn}0";

          DefaultSavePath = "/spare/data/torrents";
          TempPathEnabled = false;
          QueueingSystemEnabled = true;
          MaxActiveDownloads = 3;
          MaxActiveTorrents = 5;
          MaxActiveUploads = 3;
          # Stop seeding at ratio 1 or after 24 hours, whichever comes first.
          # Behind WARP's NAT many torrents never reach ratio 1.
          GlobalMaxRatio = 1;
          GlobalMaxSeedingMinutes = 1440;
          # Idle seeding torrents don't take up queue slots from new downloads
          IgnoreSlowTorrentsForQueueing = true;
        };
      };

      Preferences.WebUI = {
        # No password from the host (Radarr, via the namespace bridge) or the Netbird network
        LocalHostAuth = false;
        AuthSubnetWhitelistEnabled = true;
        AuthSubnetWhitelist = "100.64.0.0/10, ${config.vpnNamespaces.${vpn}.bridgeAddress}/32";
      };
    };
  };

  # Sandboxing on top of the upstream module's hardening (no capabilities, private devices,
  # protected kernel, syscall filter). Network isolation comes from the VPN namespace.
  systemd.services.qbittorrent.serviceConfig = {
    UMask = lib.mkForce "0002";

    # Whole filesystem read-only, only its own state and the download folder are writable
    ProtectSystem = lib.mkForce "strict";
    # Hide other services' state and the rest of /spare (including the movie library)
    TemporaryFileSystem = [
      "/var/lib:ro"
      "/spare:ro"
    ];
    BindPaths = [
      config.services.qbittorrent.profileDir
      "/spare/data/torrents"
    ];
    InaccessiblePaths = [
      "-/media"
      "-/files"
      "-/run/secrets"
      "-/run/secrets-for-users"
    ];

    SystemCallFilter = ["~@privileged" "~@resources"];
    MemoryMax = "4G";
  };
}
