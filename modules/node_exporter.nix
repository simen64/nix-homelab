{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "systemd"
    ];
    disabledCollectors = ["textfile"];
    openFirewall = true;
    firewallFilter = "-i wt0 -p tcp -m tcp --dport 9100";
  };
}
