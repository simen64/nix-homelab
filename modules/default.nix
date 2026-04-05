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
    ./apps/pocket-id.nix
    ./apps/uptime-kuma.nix
  ];

  homelab.services = {
    netbird.enable = lib.mkDefault true;
    webhook.enable = lib.mkDefault true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };

  boot.enableContainers = true;
  virtualisation.containers.enable = true;
}
