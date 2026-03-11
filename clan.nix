{
  # Ensure this is unique among all clans you want to use.
  meta.name = "nix-homelab";
  meta.domain = "simenmo.com";

  secrets.age.plugins = [
    "age-plugin-yubikey"
  ];

  inventory.machines = {
    main = {
      deploy.targetHost = "root@100.117.227.123";
      # Define tags here (optional)
      tags = ["nixos"];
    };
    offsite = {
      deploy.targetHost = "root@100.117.175.95";
      tags = ["nicos"];
    };
  };

  # Docs: See https://docs.clan.lol/services/definition/
  inventory.instances = {
    # Docs: https://docs.clan.lol/services/official/admin/
    # Admin service for managing machines
    # This service adds a root password and SSH access.
    admin = {
      roles.default.tags.all = {};
      roles.default.settings.allowedKeys = {
        # Insert the public key that you want to use for SSH access.
        # All keys will have ssh access to all machines ("tags.all" means 'all machines').
        # Alternatively set 'users.users.root.openssh.authorizedKeys.keys' in each machine
        "root" = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAqDkA6c7wWbeVXWv0fh0xEB2NURnL8qudQHxDVWGPAfAAAABHNzaDo= ssh:";
      };
    };

    # Docs: https://docs.clan.lol/services/official/tor/
    # Tor network provides secure, anonymous connections to your machines
    # All machines will be accessible via Tor as a fallback connection method
    tor = {
      roles.server.tags.nixos = {};
    };
  };

  # Additional NixOS configuration can be added here.
  # machines/jon/configuration.nix will be automatically imported.
  # See: https://docs.clan.lol/guides/inventory/autoincludes/
  machines = {
    main = {
      config,
      pkgs,
      ...
    }: {
      #users.users.simen.openssh.authorizedKeys.keys = [
      #  "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAqDkA6c7wWbeVXWv0fh0xEB2NURnL8qudQHxDVWGPAfAAAABHNzaDo= ssh"
      #];
    };
  };
}
