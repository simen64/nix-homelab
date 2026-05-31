{
  outputs,
  lib,
  ...
}: {
  imports = [
    #./overlays.nix
    ./netbird.nix
    ./caddy.nix
    ./watchtower.nix
    ./autoupgrade.nix
    ./webhook.nix
    ./alloy.nix
    ./node_exporter.nix  # Re-enabled: Prometheus on main scrapes this from all machines
    ./apps/pocket-id.nix
    ./apps/uptime-kuma.nix
  ];

  homelab.services = {
    netbird.enable = lib.mkDefault true;
    alloy.enable = lib.mkDefault true;
    webhook.enable = lib.mkDefault true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };

  boot.enableContainers = true;
  virtualisation.containers.enable = true;
}
