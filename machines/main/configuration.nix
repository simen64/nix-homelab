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

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  homelab.services.pocket-id = {
    enable = true;
  };
}
