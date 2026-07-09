{
  pkgs,
  config,
  ...
}: {
  imports = [
    #./modules/apps/ollama.nix
    ./modules/apps/immich.nix
    ./modules/apps/seafile
    #./modules/apps/n8n.nix
    #./modules/apps/plg-stack
    ../../modules
  ];

  # Nvidia drivers
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernelParams = ["zfs.zfs_arc_max=8589934592"];

  homelab.services = {
    pocket-id.enable = true;
    caddy.enable = true;

    # On main, Loki is co-located so we bypass the VPN and write directly
    # to localhost. This is more reliable and avoids a loopback→Netbird→loopback
    # round-trip.
    # alloy.lokiUrl = "http://127.0.0.1:3100/loki/api/v1/push";
  };
}
