# modules/auto-upgrade.nix
{config, ...}: {
  system.autoUpgrade = {
    enable = true;
    flake = "github:simen64/nix-homelab#${config.clan.core.machineName}";
    dates = "03:00";
    randomizedDelaySec = "30min";
  };
}
