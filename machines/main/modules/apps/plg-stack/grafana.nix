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

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.simenmo.com";
      };

      security.secret_key = "$__file{${config.clan.core.vars.generators.grafana_secret_key.files.grafana_secret_key.path}}";

      # Prevents Grafana from phoning home
      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          isDefault = true;
        }
      ];
    };
  };

  services.caddy.virtualHosts."grafana.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:3000
    '';
  };
}
