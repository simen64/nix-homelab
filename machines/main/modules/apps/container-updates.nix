{
  lib,
  config,
  ...
}: let
  containers = config.virtualisation.oci-containers.containers;
  unqualified = lib.filterAttrs (_: c: builtins.match "[^/]+\\.[^/]+/.*" c.image == null) containers;
in {
  # Adds the label to every container on this machine, including ones added later.
  # To opt one out: labels."io.containers.autoupdate" = "disabled";
  options.virtualisation.oci-containers.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      config.labels."io.containers.autoupdate" = lib.mkDefault "registry";
    });
  };

  config = {
    # Podman skips images without a registry, e.g. "redis" instead of "docker.io/library/redis"
    assertions = [
      {
        assertion = unqualified == {};
        message = "podman auto-update needs fully qualified images, fix: ${lib.concatStringsSep ", " (lib.attrNames unqualified)}";
      }
    ];

    systemd.timers.podman-auto-update.wantedBy = ["timers.target"];
  };
}
