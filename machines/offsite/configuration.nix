{
  imports = [
    ../../modules
  ];

  homelab.services = {
    uptime-kuma.enable = true;
    caddy.enable = true;
  };

  services.caddy.virtualHosts."uptime-offsite.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:3001
    '';
  };
}
