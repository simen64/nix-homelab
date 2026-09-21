{
  config,
  lib,
  pkgs,
  ...
}: let
  networkName = "resolve-net";
  networkService = "podman-network-${networkName}.service";
  netbirdAddress = "100.123.23.198";
  secretEnvironment = config.clan.core.vars.generators.resolve-project-server.files.environment.path;
in {
  clan.core.vars.generators.resolve-project-server = {
    prompts.postgres-password = {
      description = "DaVinci Resolve project server PostgreSQL password";
      type = "hidden";
    };

    files.environment.secret = true;

    script = ''
      printf 'POSTGRES_PASSWORD=%s\n' "$(cat "$prompts/postgres-password")" > "$out/environment"
    '';
  };

  systemd.tmpfiles.rules = [
    "d /media/resolve-project-server 0750 root root -"
    "d /media/resolve-project-server/database 0750 root root -"
    "d /files/resolve-project-server 0750 root root -"
    "d /files/resolve-project-server/backups 0750 root root -"
  ];

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  # Podman container-name DNS listens on the container bridge.
  networking.firewall.interfaces = let
    podmanInterfaces =
      if config.networking.nftables.enable
      then "podman*"
      else "podman+";
  in {
    "${podmanInterfaces}".allowedUDPPorts = [53];
    wt0.allowedTCPPorts = [5432];
  };

  systemd.services."podman-network-${networkName}" = {
    description = "Podman network for the DaVinci Resolve project server";
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f ${networkName}";
    };
    script = ''
      podman network inspect ${networkName} >/dev/null 2>&1 || podman network create ${networkName}
    '';
    wantedBy = ["multi-user.target"];
  };

  virtualisation.oci-containers.containers = {
    resolve-postgres = {
      image = "docker.io/library/postgres:13";
      autoStart = true;
      environment = {
        POSTGRES_DB = "database";
        POSTGRES_USER = "postgres";
        TZ = "Europe/Oslo";
      };
      environmentFiles = [secretEnvironment];
      volumes = [
        "/media/resolve-project-server/database:/var/lib/postgresql/data:rw"
      ];
      # Immich's native PostgreSQL already listens on localhost:5432. Bind the
      # Resolve database only to main's Netbird address so both can use 5432.
      ports = ["${netbirdAddress}:5432:5432"];
      log-driver = "journald";
      extraOptions = [
        "--network=${networkName}"
        "--network-alias=postgres"
      ];
    };

    resolve-backups = {
      image = "docker.io/prodrigestivill/postgres-backup-local:13";
      autoStart = true;
      environment = {
        POSTGRES_HOST = "postgres";
        POSTGRES_DB = "database";
        POSTGRES_USER = "postgres";
        TZ = "Europe/Oslo";
        SCHEDULE = "@daily";
        BACKUP_KEEP_DAYS = "7";
        BACKUP_KEEP_WEEKS = "4";
        BACKUP_KEEP_MONTHS = "6";
        POSTGRES_EXTRA_OPTS = "--blobs --format=custom --quote-all-identifiers";
        BACKUP_SUFFIX = ".backup";
        HEALTHCHECK_PORT = "8080";
      };
      environmentFiles = [secretEnvironment];
      volumes = [
        "/files/resolve-project-server/backups:/backups:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network=${networkName}"
      ];
    };
  };

  systemd.services.podman-resolve-postgres = {
    after = [networkService];
    requires = [networkService];
    serviceConfig.Restart = lib.mkOverride 90 "always";
  };

  systemd.services.podman-resolve-backups = {
    after = [networkService "podman-resolve-postgres.service"];
    requires = [networkService "podman-resolve-postgres.service"];
    serviceConfig.Restart = lib.mkOverride 90 "always";
  };
}
