{config, ...}: {
  clan.core.vars.generators.netbird-setup-key = {
    prompts.netbird-setup-key = {
      description = "netbird-setup-key";
      type = "hidden";
    };
    files.netbird-setup-key = {
      secret = true;
      owner = "netbird";
    };
    script = ''
      cat $prompts/netbird-setup-key > $out/netbird-setup-key
    '';
  };

  services.netbird = {
    enable = true;
  };

  users.users.netbird = {
    isSystemUser = true;
    group = "netbird";
  };
  users.groups.netbird = {};

  services.netbird.clients.default = {
    login.setupKeyFile = config.clan.core.vars.generators.netbird-setup-key.files.netbird-setup-key.path;
    #login.setupKeyFile = "/run/secrets/vars/netbird-setup-key/netbird-setup-key";
    login.enable = true;
    environment = {
      NB_MANAGEMENT_URL = "https://simenmo.com:443";
    };
    port = 51820;
    name = "netbird";
    interface = "wt0";
    hardened = false;
  };
}
