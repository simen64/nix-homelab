{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.services.caddy;
in {
  options.homelab.services.caddy = {
    enable = lib.mkEnableOption "Self-hosted ai models";
  };

  config = lib.mkIf cfg.enable {
    clan.core.vars.generators.hetzner-dns-api-key = {
      share = true;
      prompts.hetzner-dns-api-key = {
        description = "hetzner-dns-api-key";
        type = "hidden";
      };
      files.hetzner-dns-api-key = {
        secret = true;
        owner = "acme";
      };
      script = ''
        echo "HETZNER_API_TOKEN=\"$(cat $prompts/hetzner-dns-api-key)\"" > $out/hetzner-dns-api-key
      '';
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "simenmunch@gmail.com";

      certs."simenmo.com" = {
        group = config.services.caddy.group;

        domain = "simenmo.com";
        extraDomainNames = ["*.simenmo.com"];
        dnsProvider = "hetzner";
        dnsResolver = "hydrogen.ns.hetzner.com:53";
        dnsPropagationCheck = true;
        environmentFile = config.clan.core.vars.generators.hetzner-dns-api-key.files.hetzner-dns-api-key.path;
      };
    };

    services.caddy = {
      enable = true;
      extraConfig = ''
        (acme-tls) {
          tls /var/lib/acme/simenmo.com/cert.pem /var/lib/acme/simenmo.com/key.pem
        }
      '';
    };
  };
}
