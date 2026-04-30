{pkgs, ...}: {
  services.n8n = {
    enable = true;
    openFirewall = true;
  };

  services.caddy.virtualHosts."n8n.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:5768
    '';
  };
}
