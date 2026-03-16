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
    ./apps/pocket-id.nix
  ];

  homelab.services = {
    netbird.enable = lib.mkDefault true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };

  boot.enableContainers = true;
  virtualisation.containers.enable = true;
}
