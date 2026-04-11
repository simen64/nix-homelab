{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./modules/apps/ollama.nix
    ./modules/apps/immich.nix
    ./modules/apps/seafile
    ./modules/apps/plg-stack
    ../../modules
  ];

  # nvidia drivers
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  environment.systemPackages = with pkgs; [
  ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernelParams = ["zfs.zfs_arc_max=8589934592"];

  homelab.services = {
    pocket-id.enable = true;
    caddy.enable = true;
  };
}
