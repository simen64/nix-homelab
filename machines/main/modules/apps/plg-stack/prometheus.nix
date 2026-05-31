{
  config,
  self,
  ...
}: let
  inventory = builtins.fromJSON (builtins.readFile "${self}/inventory.json");
  machineNames = builtins.attrNames inventory.machines;

  nodeExporterPort = toString config.services.prometheus.exporters.node.port;
  # Produces ["main:9100", "offsite:9100", "vps:9100", "im-backup:9100"].
  # Resolution relies on Netbird MagicDNS; if a machine doesn't resolve, its
  # scrapes will simply show up as "down" in Grafana without breaking others.
  nodeTargets = map (name: "${name}:${nodeExporterPort}") machineNames;
in {
  services.prometheus = {
    enable = true;

    # Bind to loopback only — Grafana is co-located and this avoids exposing
    # the Prometheus API on the Netbird interface unnecessarily.
    listenAddress = "127.0.0.1";
    port = 9090;

    globalConfig.scrape_interval = "30s";

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = nodeTargets;
          }
        ];
      }
    ];
  };
}
