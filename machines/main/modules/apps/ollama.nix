{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.services.ollama;
in {
  options.homelab.services.ollama = {
    enable = lib.mkEnableOption "Self-hosted ai models";

    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama-cuda;
      loadModels = cfg.models;
    };
  };
}
