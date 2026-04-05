{
  lib,
  config,
  ...
}: let
  cfg = config.homelab.services.webhook;
in {
  options.homelab.services.webhook = {
    enable = lib.mkEnableOption "automatic updates with watchtower";
  };
  config = lib.mkIf cfg.enable {
    clan.core.vars.generators.webhook-secret = {
      share = true;
      prompts.webhook-secret = {
        description = "webhook-secret";
        type = "hidden";
      };
      files.webhook-secret = {
        secret = true;
        owner = "webhook";
      };
      script = ''
        cat $prompts/webhook-secret > $out/webhook-secret
      '';
    };

    systemd.services.nixos-rebuild-webhook = {
      description = "NixOS rebuild triggered by webhook";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/nixos-rebuild switch --flake github:simen64/nix-homelab";
      };
    };

    security.sudo.extraRules = [
      {
        users = ["webhook"];
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl start nixos-rebuild-webhook";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    services.webhook = {
      enable = true;
      extraArgs = [
        "-template"
      ];
      hooksTemplated = {
        redeploy = ''
          {
            "execute-command": "/run/wrappers/bin/sudo",
            "id": "redeploy",
            "pass-arguments-to-command": [
              {
                "name": "/run/current-system/sw/bin/systemctl",
                "source": "string"
              },
              {
                "name": "start",
                "source": "string"
              },
              {
                "name": "nixos-rebuild-webhook",
                "source": "string"
              }
            ],
            "trigger-rule": {
              "match": {
                "parameter": {
                  "name": "X-Hub-Signature-256",
                  "source": "header"
                },
                "secret": "{{ cat "${config.clan.core.vars.generators.webhook-secret.files.webhook-secret.path}" | js }}",
                "type": "payload-hmac-sha256"
              }
            }
          }
        '';
      };
    };
  };
}
