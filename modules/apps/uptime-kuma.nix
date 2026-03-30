{
  lib,
  config,
  ...
}: let
  cfg = config.homelab.services.uptime-kuma;
in {
  options.homelab.services.uptime-kuma = {
    enable = lib.mkEnableOption "automatic updates with uptime-kuma";
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma.enable = true;
  };
}
