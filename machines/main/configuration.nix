{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./modules/apps/immich.nix
    ./modules/apps/seafile
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

  homelab.services.pocket-id = {
    enable = true;
  };
}
