{...}: {
  imports = [
    ./prometheus.nix
    ./loki.nix
    ./grafana.nix
  ];
}
