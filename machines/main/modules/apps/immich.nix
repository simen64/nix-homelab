{config, ...}: {
  services.immich = {
    enable = true;
    port = 2283;

    host = "0.0.0.0";
    openFirewall = true;

    mediaLocation = "/media/";

    accelerationDevices = null;
  };

  users.users.immich.extraGroups = ["video" "render"];

  clan.core.state.immich = {
    folders = [
      "/media/library"
      "/media/upload"
      "/media/profile"
      "/media/backups"
    ];
  };

  homelab.services.caddy.enable = true;
  services.caddy.virtualHosts."immich.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:2283
    '';
  };
}
