{
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    #./overlays.nix
    ./netbird.nix
    ./caddy.nix
    ./watchtower.nix
    ./autoupgrade.nix
    ./ca-blacklist.nix
    ./webhook.nix
    #./alloy.nix
    #./node_exporter.nix # Re-enabled: Prometheus on main scrapes this from all machines
    ./apps/pocket-id.nix
    ./apps/uptime-kuma.nix
  ];

  homelab.services = {
    netbird.enable = lib.mkDefault true;
    # alloy.enable = lib.mkDefault true;
    webhook.enable = lib.mkDefault true;
  };

  environment.systemPackages = [
    pkgs.net-tools
  ];

  # Old generations and store paths are never removed otherwise
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

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
