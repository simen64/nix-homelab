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

  homelab.services.caddy.enable = true;
  services.caddy.virtualHosts."immich.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:2283
    '';
  };
}
