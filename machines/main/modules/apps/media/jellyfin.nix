{...}: {
  services.jellyfin = {
    enable = true;

    # NVENC on the Nvidia card
    hardwareAcceleration = {
      enable = true;
      type = "nvenc";
      device = "/dev/nvidia0";
    };
    transcoding.enableHardwareEncoding = true;
  };

  users.users.jellyfin.extraGroups = ["media" "video" "render"];

  # NVENC needs the control/uvm devices in addition to /dev/nvidia0
  systemd.services.jellyfin.serviceConfig.DeviceAllow = [
    "/dev/nvidiactl rw"
    "/dev/nvidia-uvm rw"
    "/dev/nvidia-uvm-tools rw"
    "/dev/nvidia-modeset rw"
  ];

  services.caddy.virtualHosts."jellyfin.simenmo.com" = {
    extraConfig = ''
      import acme-tls
      reverse_proxy localhost:8096
    '';
  };
}
