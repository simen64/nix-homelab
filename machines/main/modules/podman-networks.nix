{
  lib,
  config,
  ...
}: let
  podman = "${config.virtualisation.podman.package}/bin/podman";

  # The custom network a container joins through --network=<name>, if any
  networkOf = c: let
    flags = builtins.filter (o: lib.hasPrefix "--network=" o) c.extraOptions;
    name = lib.removePrefix "--network=" (lib.head flags);
  in
    if flags == [] || lib.elem name ["host" "none" "bridge" "private"]
    then null
    else name;

  withNetwork = lib.filterAttrs (_: c: networkOf c != null) config.virtualisation.oci-containers.containers;
in {
  # The weekly `podman system prune` deletes networks no running container uses, and the
  # podman-network-* units stay "active" afterwards, so nothing recreates them. Create the
  # network right before each container starts instead. The last check covers two containers
  # on the same network starting at once.
  systemd.services = lib.mapAttrs' (name: c:
    lib.nameValuePair "podman-${name}" {
      preStart = lib.mkBefore ''
        ${podman} network exists ${networkOf c} \
          || ${podman} network create ${networkOf c} \
          || ${podman} network exists ${networkOf c}
      '';
    })
  withNetwork;
}
