{pkgs, ...}: let
  dirs = ["/spare/data/torrents" "/spare/data/media"];
  quarantine = "/spare/data/quarantine";
in {
  # Keeps the virus definitions in /var/lib/clamav up to date
  services.clamav.updater.enable = true;

  # Hourly scan of new files in downloads and the library, infected files are moved to quarantine.
  # The unit fails when something is found, so it shows up in `systemctl --failed`.
  systemd.services.media-scan = {
    description = "ClamAV scan of new media downloads";
    path = [pkgs.clamav pkgs.findutils pkgs.coreutils];
    unitConfig.ConditionPathExistsGlob = "/var/lib/clamav/main.c*d";

    script = ''
      stamp="$STATE_DIRECTORY/last-scan"
      next="$STATE_DIRECTORY/next-scan"
      list="$(mktemp)"
      touch "$next"

      # Only files created or hardlinked since the last successful scan
      if [[ -e $stamp ]]; then
        find ${toString dirs} -type f -cnewer "$stamp" > "$list"
      else
        find ${toString dirs} -type f > "$list"
      fi

      if [[ -s $list ]]; then
        clamscan \
          --database=/var/lib/clamav \
          --infected \
          --move=${quarantine} \
          --file-list="$list"
      fi

      mv "$next" "$stamp"
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "clamav";
      Group = "clamav";
      SupplementaryGroups = ["media"];
      StateDirectory = "media-scan";

      Nice = 19;
      IOSchedulingClass = "idle";

      ProtectSystem = "strict";
      ReadWritePaths = ["/spare/data"];
      PrivateTmp = true;
      PrivateNetwork = true;
      PrivateDevices = true;
      ProtectHome = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = ["AF_UNIX"];
      SystemCallFilter = ["@system-service"];
    };
  };

  systemd.timers.media-scan = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
