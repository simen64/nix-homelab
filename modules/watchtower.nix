{
  lib,
  config,
  ...
}: let
  cfg = config.homelab.services.watchtower;
in {
  options.homelab.services.watchtower = {
    enable = lib.mkEnableOption "automatic updates with watchtower";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."watchtower" = {
      autoStart = true;
      image = "containrrr/watchtower";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };
}
