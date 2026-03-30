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
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers."watchtower" = {
      autoStart = true;
      image = "nickfedor/watchtower";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
  };
}
