{
  lib,
  config,
  ...
}: {
  virtualisation.oci-containers.containers."seafile-mysql" = {
    image = "mariadb:10.11";
    environmentFiles = ["/run/seafile-mysql-secrets.env"];
    environment = {
      "MARIADB_AUTO_UPGRADE" = "1";
      "MYSQL_LOG_CONSOLE" = "true";
    };
    volumes = [
      "/files/seafile-mysql/db:/var/lib/mysql:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"/usr/local/bin/healthcheck.sh\", \"--connect\", \"--mariadbupgrade\", \"--innodb_initialized\"]"
      "--health-interval=20s"
      "--health-retries=10"
      "--health-start-period=30s"
      "--health-timeout=5s"
      "--network-alias=db"
      "--network=seafile-net"
    ];
  };
  systemd.services."podman-seafile-mysql" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      PermissionsStartOnly = true;
    };
    preStart = let
      mysqlRootPass = config.clan.core.vars.generators.seafile-mysql-password.files.password.path;
    in ''
      mkdir -p /files/seafile-mysql/db
      install -m 600 /dev/null /run/seafile-mysql-secrets.env
      echo "MYSQL_ROOT_PASSWORD=$(cat ${mysqlRootPass})" >> /run/seafile-mysql-secrets.env
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
