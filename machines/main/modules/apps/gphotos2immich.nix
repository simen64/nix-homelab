{config, ...}: {
  clan.core.vars.generators.immich-api-key = {
    prompts.immich-api-key = {
      description = "immich-api-key";
      type = "hidden";
    };
    files.immich-api-key = {
      secret = true;
    };
    script = ''
      echo "IMMICH_API_KEY=$(cat $prompts/immich-api-key)" > $out/immich-api-key
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/gphotos2immich/data 0750 root root -"
    "f /var/lib/gphotos2immich/config.json 0644 root root - ${builtins.toJSON {
      debug = true;
      googlePhotos = [];
      workers = 5;
    }}"
  ];

  virtualisation.oci-containers.containers.gphotos2immich = {
    image = "ghcr.io/warreth/gphotos2immich:latest";
    autoStart = true;

    environment = {
      PORT = "8889"; # Port for the Web UI
      DISABLE_WEBUI = "true"; # Set to "true" to fully disable the Web UI
      TZ = "UTC+02:00";
      IMMICH_API_URL = "https://immich.simenmo.com/api";
    };
    environmentFiles = [
      config.clan.core.vars.generators.immich-api-key.files.immich-api-key.path
    ];

    volumes = [
      "/var/lib/gphotos2immich/config.json:/app/config.json" # Optional, created by Web UI
      "/var/lib/gphotos2immich/data:/app/data" # Persistent dedup cache
    ];

    extraOptions = [
      "--network=host" # Fixes DNS resolution, exposes 8080 natively
    ];
  };
}
