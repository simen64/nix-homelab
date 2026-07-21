{
  config,
  pkgs,
  ...
}: {
  clan.core.vars.generators.discord-bot-secrets = {
    prompts = {
      discord-token = {
        description = "Discord bot token";
        type = "hidden";
      };
      ghcr-token = {
        description = "GitHub PAT with read:packages scope (for ghcr.io pull)";
        type = "hidden";
      };
    };
    files = {
      discord-token = {
        secret = true;
      };
      ghcr-token = {
        secret = true;
      };
    };
    script = ''
      echo "DISCORD_TOKEN=$(cat $prompts/discord-token)" > $out/discord-token
      cat $prompts/ghcr-token > $out/ghcr-token
    '';
  };

  virtualisation.oci-containers.containers.discord-bot = {
    image = "ghcr.io/simen64/discord-assistant-bot:latest";
    login = {
      registry = "ghcr.io";
      username = "simen64";
      passwordFile = config.clan.core.vars.generators.discord-bot-secrets.files.ghcr-token.path;
    };
    autoStart = true;
    environment = {
      BOT_PREFIX = "!";
    };
    environmentFiles = [
      config.clan.core.vars.generators.discord-bot-secrets.files.discord-token.path
    ];
    volumes = [
      "/var/lib/gphotos2immich:/var/lib/gphotos2immich"
    ];
  };
}
