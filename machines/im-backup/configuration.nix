{
  imports = [
    ../../modules
  ];

  homelab.services = {
    uptime-kuma.enable = true;
    caddy.enable = true;
  };

  services.caddy.virtualHosts."uptime-im.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:3001
    '';
  };
}
