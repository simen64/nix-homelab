{...}: {
  # Request UI, log in with your Jellyfin account
  services.seerr = {
    enable = true;
    port = 5055;
  };

  services.caddy.virtualHosts."requests.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:5055
    '';
  };
}
