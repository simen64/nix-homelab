{
  config,
  self,
  ...
}: let
  inventory = builtins.fromJSON (builtins.readFile "${self}/inventory.json");
  machineNames = builtins.attrNames inventory.machines;

  nodeExporterPort = toString config.services.prometheus.exporters.node.port;
  nodeTargets = map (name: "${name}:${nodeExporterPort}") machineNames;
in {
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s"; # "1m"
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
