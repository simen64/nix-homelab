{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.webhook;
in {
  options.homelab.services.webhook = {
    enable = lib.mkEnableOption "the redeploy webhook (adnanh/webhook on port 9000) that runs nixos-rebuild from GitHub when the push-config workflow calls it";

    openFirewallOn = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["wt0"];
      description = "Network interfaces on which TCP port 9000 is opened for the webhook. Defaults to the Netbird interface only.";
    };

    openPublicly = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open TCP port 9000 on all interfaces, including public ones.
        Only for machines that cannot be reached over Netbird (e.g. the VPS
        that runs the Netbird server itself).
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    clan.core.vars.generators = {
      webhook-secret = {
        share = true;
        prompts.webhook-secret = {
          description = "webhook-secret";
          type = "hidden";
        };
        files.webhook-secret = {
          secret = true;
          owner = "webhook";
          # The hooks template reads the secret only at startup
          restartUnits = ["webhook.service"];
        };
        script = ''
          cat $prompts/webhook-secret > $out/webhook-secret
        '';
      };
      discord-webhook-url = {
        share = true;
        prompts.discord-webhook-url = {
          description = "webhook-secret";
          type = "hidden";
        };
        files.discord-webhook-url = {
          secret = true;
          owner = "root";
        };
        script = ''
          cat $prompts/discord-webhook-url > $out/discord-webhook-url
        '';
      };
    };

    systemd.services = {
      nixos-rebuild-webhook = {
        description = "NixOS rebuild triggered by webhook";

        unitConfig.OnFailure = [
          "discord-notify-failure@%n.service"
        ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/nixos-rebuild switch --flake github:simen64/nix-homelab --refresh";
          Delegate = "yes";
        };
      };

      "discord-notify-failure@" = {
        description = "Notify Discord when a systemd service fails";
        wants = ["network-online.target"];
        after = ["network-online.target"];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Environment = ["FAILED_UNIT=%i"];
          LoadCredential = ["webhook-url:${config.clan.core.vars.generators.discord-webhook-url.files.discord-webhook-url.path}"];

          ExecStart = pkgs.writeShellScript "discord-notify-failure" ''
            set -eu
            FAILED_UNIT="''${FAILED_UNIT%.service}"
            WEBHOOK_URL="$(cat "$CREDENTIALS_DIRECTORY/webhook-url")"
            CONTENT="🚨 $FAILED_UNIT failed on $(/run/current-system/sw/bin/hostname) at $(/run/current-system/sw/bin/date -Is)"
            ${pkgs.curl}/bin/curl --max-time 15 --form-string "content=$CONTENT" "$WEBHOOK_URL"
          '';
        };
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
              "and": [
                {
                  "match": {
                    "parameter": {
                      "name": "X-Hub-Signature-256",
                      "source": "header"
                    },
                    "secret": "{{ cat "${config.clan.core.vars.generators.webhook-secret.files.webhook-secret.path}" | js }}",
                    "type": "payload-hmac-sha256"
                  }
                },
                {
                  "match": {
                    "parameter": {
                      "name": "ref",
                      "source": "payload"
                    },
                    "type": "value",
                    "value": "refs/heads/main"
                  }
                }
              ]
            }
          }
        '';
      };
    };

    networking.firewall =
      if cfg.openPublicly
      then {allowedTCPPorts = [9000];}
      else {
        interfaces = lib.genAttrs cfg.openFirewallOn (_: {allowedTCPPorts = [9000];});
      };
  };
}
