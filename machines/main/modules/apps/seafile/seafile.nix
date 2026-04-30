{
  lib,
  pkgs,
  config,
  ...
}: {
  clan.core.vars.generators = {
    seafile-secrets = {
      files.INIT_SEAFILE_ADMIN_PASSWORD = {secret = true;};
      script = ''
        echo $(openssl rand -base64 32) > $out/INIT_SEAFILE_ADMIN_PASSWORD
      '';
      runtimeInputs = [pkgs.openssl];
    };
  };

  # Write an env file at runtime from the secret paths
  systemd.services."podman-seafile" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      # Run preStart as root so it can read secrets and write the env file
      PermissionsStartOnly = true;
    };
    preStart = let
      mysqlPass = config.clan.core.vars.generators.seafile-mysql-password.files.password.path;
      redisPass = config.clan.core.vars.generators.seafile-redis-password.files.password.path;
      mysqlRootPass = config.clan.core.vars.generators.seafile-mysql-password.files.password.path;
      jwtKey = config.clan.core.vars.generators.seafile-jwt-private-key.files.password.path;
    in ''
      mkdir -p /files/seafile
      mkdir -p /files/seafile/seafile/logs
      install -m 600 /dev/null /run/seafile-secrets.env
      {
        echo "INIT_SEAFILE_MYSQL_ROOT_PASSWORD=$(cat ${mysqlRootPass})"
        echo "JWT_PRIVATE_KEY=$(cat ${jwtKey})"
        echo "SEAFILE_MYSQL_DB_PASSWORD=$(cat ${mysqlPass})"
        echo "REDIS_PASSWORD=$(cat ${redisPass})"
      } >> /run/seafile-secrets.env
    '';
    after = ["podman-network-seafile-net.service"];
    requires = ["podman-network-seafile-net.service"];
    partOf = ["podman-compose-seafile-root.target"];
    wantedBy = ["podman-compose-seafile-root.target"];
  };

  virtualisation.oci-containers.containers."seafile" = {
    image = "seafileltd/seafile-mc:13.0-latest";
    environmentFiles = ["/run/seafile-secrets.env"];
    environment = {
      "CACHE_PROVIDER" = "redis";
      "ENABLE_FACE_RECOGNITION" = "false";
      "ENABLE_GO_FILESERVER" = "true";
      "ENABLE_NOTIFICATION_SERVER" = "true";
      "ENABLE_SEADOC" = "false";
      "ENABLE_SEAFILE_AI" = "false";
      "INIT_SEAFILE_ADMIN_EMAIL" = "me@example.com";
      "INIT_SEAFILE_ADMIN_PASSWORD" = "changeme";
      "INNER_NOTIFICATION_SERVER_URL" = "http://notification-server:8083";
      "MD_FILE_COUNT_LIMIT" = "100000";
      "NON_ROOT" = "false";
      "NOTIFICATION_SERVER_URL" = "https://seafile.simenmo.com/notification";
      "REDIS_HOST" = "redis";
      "REDIS_PORT" = "6379";
      "SEAFILE_LOG_TO_STDOUT" = "false";
      "SEAFILE_MYSQL_DB_CCNET_DB_NAME" = "ccnet_db";
      "SEAFILE_MYSQL_DB_HOST" = "db";
      "SEAFILE_MYSQL_DB_PORT" = "3306";
      "SEAFILE_MYSQL_DB_SEAFILE_DB_NAME" = "seafile_db";
      "SEAFILE_MYSQL_DB_SEAHUB_DB_NAME" = "seahub_db";
      "SEAFILE_MYSQL_DB_USER" = "seafile";
      "SEAFILE_SERVER_HOSTNAME" = "2ef1ef6cf32fa2d50245dee92f924e19.vpn.simenmo.com";
      "SEAFILE_SERVER_PROTOCOL" = "https";
      "SITE_ROOT" = "/";
      "TIME_ZONE" = "Etc/UTC";
    };
    volumes = ["/files/seafile:/shared:rw"];
    ports = ["8080:80/tcp"];
    dependsOn = ["seafile-mysql" "seafile-redis"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=curl -f http://localhost:8080 || exit 1"
      "--health-interval=30s"
      "--health-retries=3"
      "--health-start-period=10s"
      "--health-timeout=10s"
      "--network-alias=seafile"
      "--network=seafile-net"
    ];
  };
}
