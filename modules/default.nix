{
  config,
  outputs,
  ...
}: {
  imports = [
    #./overlays.nix
    ./netbird.nix
    ./caddy.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
  };
}
