{pkgs, ...}: {
  services.immich = {
    enable = true;
    package = pkgs.unstable.immich;
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

  services.caddy.virtualHosts."immich.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:2283
    '';
  };
}
