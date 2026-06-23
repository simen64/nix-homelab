{
  pkgs,
  config,
  ...
}: {
  clan.core.vars.generators.grafana_secret_key = {
    files.grafana_secret_key = {
      secret = true;
      owner = "grafana";
    };
    script = ''
      echo $(openssl rand -hex 32) > $out/grafana_secret_key
    '';
    runtimeInputs = [pkgs.openssl];
  };

  clan.core.vars.generators.grafana_discord_webhook = {
    prompts.grafana_discord_webhook = {
      description = "Discord webhook URL for Grafana alerts (https://discord.com/api/webhooks/...)";
      type = "hidden";
    };
    files.grafana_discord_webhook = {
      secret = true;
      owner = "grafana";
    };
    # Grafana reads this as an EnvironmentFile and expands $DISCORD_WEBHOOK_URL
    # in the provisioned contact-point config below.
    script = ''
      echo "DISCORD_WEBHOOK_URL=$(cat $prompts/grafana_discord_webhook)" > $out/grafana_discord_webhook
    '';
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.simenmo.com";
        root_url = "https://grafana.simenmo.com";
      };

      security.secret_key = "$__file{${config.clan.core.vars.generators.grafana_secret_key.files.grafana_secret_key.path}}";

      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          # Pinned UID so alert rules can reference it deterministically.
          uid = "prometheus";
          name = "Prometheus";
          type = "prometheus";
          # listenAddress is "127.0.0.1" in prometheus.nix, so this URL is correct.
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          isDefault = true;
        }
        {
          uid = "loki";
          name = "Loki";
          type = "loki";
          url = "http://127.0.0.1:3100";
        }
      ];

      alerting = {
        # ---------- Contact point: Discord ----------
        contactPoints.settings = {
          apiVersion = 1;
          contactPoints = [
            {
              orgId = 1;
              name = "Discord";
              receivers = [
                {
                  uid = "discord";
                  type = "discord";
                  settings = {
                    # Expanded at Grafana startup from the EnvironmentFile below.
                    url = "$DISCORD_WEBHOOK_URL";
                    username = "Grafana";
                  };
                }
              ];
            }
          ];
        };

        # ---------- Root notification policy ----------
        # All alerts → Discord, no further matchers needed.
        policies.settings = {
          apiVersion = 1;
          policies = [
            {
              orgId = 1;
              receiver = "Discord";
              group_by = ["alertname" "host"];
              group_wait = "30s";
              group_interval = "5m";
              repeat_interval = "4h";
            }
          ];
        };

        # ---------- Alert rules ----------
        rules.settings = {
          apiVersion = 1;
          groups = [
            {
              orgId = 1;
              name = "systemd";
              folder = "Homelab";
              interval = "1m";
              rules = [
                # Fires whenever any systemd unit enters the "failed" state.
                # Loki query counts matching log lines over the last 5 minutes;
                # the threshold expression fires when the count is > 0.
                {
                  uid = "systemd-service-failure";
                  title = "Systemd Service Failed";
                  # "C" is the threshold expression that sets the alert state.
                  condition = "C";
                  for = "0s";
                  noDataState = "OK";
                  execErrState = "Alerting";
                  annotations = {
                    summary = "A systemd service entered failed state";
                    description = "Check 'journalctl -u <unit> -b' on the affected host for details.";
                  };
                  labels = {};
                  data = [
                    # A — Loki metric query (instant)
                    {
                      refId = "A";
                      relativeTimeRange = {
                        from = 60; # 1 minute
                        to = 0;
                      };
                      datasourceUid = "loki";
                      model = {
                        datasource = {
                          type = "loki";
                          uid = "loki";
                        };
                        editorMode = "code";
                        # Counts log lines containing the exact phrase systemd
                        # emits when a service transitions to failed.
                        expr = ''count_over_time({job="systemd-journal"} |= "entered failed state" | regexp `systemd\\[\\d+\\]: (?P<unit>\\S+\\.service): entered failed state` [1m])'';
                        instant = true;
                        queryType = "instant";
                        refId = "A";
                      };
                    }
                    # C — Threshold: alert when A > 0
                    {
                      refId = "C";
                      relativeTimeRange = {
                        from = 60;
                        to = 0;
                      };
                      datasourceUid = "__expr__";
                      model = {
                        conditions = [
                          {
                            evaluator = {
                              params = [0];
                              type = "gt";
                            };
                            operator.type = "and";
                            query.params = ["A"];
                            reducer = {
                              params = [];
                              type = "last";
                            };
                            type = "query";
                          }
                        ];
                        datasource = {
                          type = "__expr__";
                          uid = "__expr__";
                        };
                        expression = "A";
                        intervalMs = 1000;
                        maxDataPoints = 43200;
                        refId = "C";
                        type = "threshold";
                      };
                    }
                  ];
                  isPaused = false;
                }
              ];
            }
          ];
        };
      };
    };
  };

  # Inject the Discord webhook URL into the Grafana process environment.
  # The "-" prefix means systemd silently ignores a missing file (e.g. before
  # the var is first generated with `clan vars generate`).
  systemd.services.grafana.serviceConfig.EnvironmentFile = [
    "-${config.clan.core.vars.generators.grafana_discord_webhook.files.grafana_discord_webhook.path}"
  ];

  services.caddy.virtualHosts."grafana.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:3000
    '';
  };
}
