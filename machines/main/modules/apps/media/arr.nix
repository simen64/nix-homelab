{lib, ...}: {
  # Radarr: finds releases, sends them to the download client, renames and imports into the library
  services.radarr = {
    enable = true;
    group = "media";
  };
  systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";

  # Prowlarr: manages torrent indexers and syncs them to Radarr
  services.prowlarr.enable = true;

  # Admin UIs are only reachable over Netbird
  networking.firewall.interfaces."wt0".allowedTCPPorts = [
    7878 # radarr
    9696 # prowlarr
  ];
}
