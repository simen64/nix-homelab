{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.homelab.services.alloy;

  alloyConfig = pkgs.writeText "alloy-logs.hcl" ''
    // ── Relabeling ──────────────────────────────────────────────────────────────
    // Promote two journal fields to top-level Loki labels so they can be used
    // in log queries and alert rules.
    loki.relabel "journal" {
      forward_to = []

      // _SYSTEMD_UNIT → label "unit"  (e.g. "caddy.service")
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }

      // PRIORITY_KEYWORD → label "level"  (e.g. "err", "warning", "info")
      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "level"
      }
    }

    // ── Journal source ───────────────────────────────────────────────────────────
    loki.source.journal "read" {
      forward_to    = [loki.write.default.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels = {
        job  = "systemd-journal",
        host = "${config.networking.hostName}",
      }
    }

    // ── Loki writer ──────────────────────────────────────────────────────────────
    loki.write "default" {
      endpoint {
        url = "${cfg.lokiUrl}"
      }
    }
  '';
in {
  options.homelab.services.alloy = {
    enable = lib.mkEnableOption "Grafana Alloy log shipping to Loki";

    lokiUrl = lib.mkOption {
      type = lib.types.str;
      # Default: main machine's Netbird IP.
      # Override to "http://127.0.0.1:3100/loki/api/v1/push" on the main
      # machine itself (see machines/main/configuration.nix).
      default = "http://100.123.23.198:3100/loki/api/v1/push";
      description = "Loki push endpoint URL that Alloy ships logs to.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      configPath = alloyConfig;
    };

    # Add the alloy system user to the groups needed to read the journal.
    # We only set extraGroups here and let the NixOS alloy module own
    # everything else (isSystemUser, group, etc.) to avoid conflicts.
    users.users.alloy = {
      isSystemUser = true;
      group = "alloy";
      extraGroups = [
        "adm"
        "systemd-journal"
      ];
    };
    users.groups.alloy = {};
  };
}
