{config, ...}: {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    # "systemd" collector exposes unit states (ActiveState, SubState etc.)
    # which powers the node-level overview panels in Grafana.
    enabledCollectors = ["systemd"];
    disabledCollectors = ["textfile"];
    # openFirewall opens port 9100 but restricts it to the Netbird interface
    # via firewallFilter, so the exporter is not reachable from the LAN or WAN.
    openFirewall = true;
    firewallFilter = "-i wt0 -p tcp -m tcp --dport 9100";
  };

  # Prometheus on 'main' scrapes "main:9100".  Netbird MagicDNS resolves
  # "main" to the Netbird IP (100.123.23.198), so the probe arrives on wt0
  # and the firewallFilter above already covers it.
  #
  # If you ever want to scrape via loopback (e.g. for local dashboards without
  # Netbird), un-comment the line below:
  #   networking.firewall.interfaces."lo".allowedTCPPorts = [9100];
}
