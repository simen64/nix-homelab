{
  lib,
  config,
  ...
}: {
  virtualisation.oci-containers.containers."notification-server" = {
    image = "seafileltd/notification-server:13.0-latest";
    environment = {
      "NOTIFICATION_SERVER_LOG_LEVEL" = "info";
      "SEAFILE_LOG_TO_STDOUT" = "false";
      "SEAFILE_MYSQL_DB_CCNET_DB_NAME" = "ccnet_db";
      "SEAFILE_MYSQL_DB_HOST" = "db";
      "SEAFILE_MYSQL_DB_PORT" = "3306";
      "SEAFILE_MYSQL_DB_SEAFILE_DB_NAME" = "seafile_db";
      "SEAFILE_MYSQL_DB_USER" = "seafile";
    };
    volumes = [
      "/files/seafile/seafile/logs:/shared/seafile/logs:rw"
    ];
    ports = [
      "8083:8083/tcp"
    ];
    dependsOn = [
      "seafile"
      "seafile-mysql"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=notification-server"
      "--network=seafile-net"
    ];
  };
  systemd.services."podman-notification-server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      PermissionsStartOnly = true;
    };
    preStart = let
      mysqlPass = config.clan.core.vars.generators.seafile-mysql-password.files.password.path;
      jwtKey = config.clan.core.vars.generators.seafile-jwt-private-key.files.password.path;
    in ''
      install -m 600 /dev/null /run/seafile-notification-secrets.env
      {
        echo "SEAFILE_MYSQL_DB_PASSWORD=$(cat ${mysqlPass})"
        echo "JWT_PRIVATE_KEY=$(cat ${jwtKey})"
      } >> /run/seafile-notification-secrets.env
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
