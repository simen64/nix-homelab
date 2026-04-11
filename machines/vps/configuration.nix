{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../../modules
  ];

  homelab.services = {
    pocket-id = {
      enable = true;
      app_url = "https://idp.simenmo.com";
      host = "0.0.0.0";
    };
    watchtower.enable = true;
    netbird.enable = false;
  };

  environment.systemPackages = with pkgs; [
    openssl
  ];

  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = ["docker0"];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i br+ -j ACCEPT
    iptables -A FORWARD -i br+ -j ACCEPT
    iptables -A FORWARD -o br+ -j ACCEPT
  '';

  virtualisation.docker = {
    enable = true;
  };

  clan.core.state.netbird = {
    folders = [
      "/home/simen/netbird"
      "/var/lib/netbird"
    ];
    preBackupScript = ''
      export PATH=${lib.makeBinPath [config.systemd.package]}:$PATH
      docker compose stop netbird-server
    '';
    postBackupScript = ''
      export PATH=${lib.makeBinPath [config.systemd.package]}:$PATH
      docker compose start netbird-server
    '';
  };
}
