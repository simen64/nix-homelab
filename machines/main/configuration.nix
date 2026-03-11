{
  pkgs,
  config,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./modules/apps/immich.nix
    ../../modules
  ];

  nixpkgs.config.allowUnfree = true;

  # nvidia drivers
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  environment.systemPackages = with pkgs; [
    unstable.llmfit
  ];
}
