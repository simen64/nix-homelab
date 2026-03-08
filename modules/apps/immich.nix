{ config, ... }:

{
  options.homelab.services.immich = {
    enable = lib.mkEnableOption "Self-hosted photo and video management solution"
  };
};
