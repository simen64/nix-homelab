{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.pocket-id;
in {
  options.homelab.services.pocket-id = {
    enable = lib.mkEnableOption "Passkey based OIDC";

    app_url = lib.mkOption {
      type = lib.types.str;
      default = "https://pocket-id.simenmo.com";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };
  };

  config = lib.mkIf cfg.enable {
    clan.core.vars.generators = {
      maxmind-license-key = {
        share = true;
        prompts.maxmind-license-key = {
          description = "maxmind-license-key";
          type = "hidden";
        };
        files.maxmind-license-key = {
          secret = true;
          owner = "pocket-id";
        };
        script = ''
          cat $prompts/maxmind-license-key > $out/maxmind-license-key
        '';
      };
      encryption-key = {
        files.encryption-key = {
          secret = true;
          owner = "pocket-id";
        };
        script = ''
          echo $(openssl rand -base64 32) > $out/encryption-key
        '';
        runtimeInputs = [pkgs.openssl];
      };
    };

    services.pocket-id = {
      enable = true;
      package = pkgs.unstable.pocket-id;

      settings = {
        HOST = cfg.host;
        TRUST_PROXY = true;
        APP_URL = cfg.app_url;
      };

      credentials = {
        MAXMIND_LICENSE_KEY = config.clan.core.vars.generators.maxmind-license-key.files.maxmind-license-key.path;
        ENCRYPTION_KEY = config.clan.core.vars.generators.encryption-key.files.encryption-key.path;
      };
    };
    services.caddy.virtualHosts."pocket-id.simenmo.com" = {
      extraConfig = ''
        import acme-tls
        reverse_proxy localhost:1411
      '';
    };
    clan.core.state.pocket-id = {
      folders = [
        "/var/lib/pocket-id"
      ];
    };
  };
}
