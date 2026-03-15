{
  lib,
  config,
  ...
}: {
  virtualisation.oci-containers.containers."seafile-redis" = {
    image = "redis";
    environmentFiles = ["/run/seafile-redis-secrets.env"];
    cmd = ["/bin/sh" "-c" "redis-server --requirepass \"$REDIS_PASSWORD\""];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=seafile-net"
    ];
  };
  systemd.services."podman-seafile-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      # Run preStart as root so it can read secrets and write the env file
      PermissionsStartOnly = true;
    };
    preStart = let
      redisPass = config.clan.core.vars.generators.seafile-redis-password.files.password.path;
    in ''
      install -m 600 /dev/null /run/seafile-redis-secrets.env
      echo "REDIS_PASSWORD=$(cat ${redisPass})" >> /run/seafile-redis-secrets.env
    '';
    after = [
      "podman-network-seafile-net.service"
    ];
    requires = [
      "podman-network-seafile-net.service"
    ];
    partOf = [
      "podman-compose-seafile-root.target"
    ];
    wantedBy = [
      "podman-compose-seafile-root.target"
    ];
  };
}
