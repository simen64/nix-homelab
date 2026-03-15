{outputs, ...}: {
  imports = [
    #./overlays.nix
    ./netbird.nix
    ./caddy.nix
    ./apps/pocket-id.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };

  boot.enableContainers = true;
  virtualisation.containers.enable = true;
}
