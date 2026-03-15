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

  inventory.instances = {
    admin = {
      roles.default.tags.all = {};
      roles.default.settings.allowedKeys = {
        # Insert the public key that you want to use for SSH access.
        # All keys will have ssh access to all machines ("tags.all" means 'all machines').
        # Alternatively set 'users.users.root.openssh.authorizedKeys.keys' in each machine
        "root" = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAqDkA6c7wWbeVXWv0fh0xEB2NURnL8qudQHxDVWGPAfAAAABHNzaDo= ssh:";
      };
    };

    borgbackup = {
      module = {
        name = "borgbackup";
        input = "clan-core";
      };

      roles.client.machines = {
        "main".settings = {
          startAt = "*-*-* 02:00:00";
        };
      };

      roles.server.machines = {
        "offsite".settings = {
          directory = "/storage/borgbackup";
        };
      };
    };
  };

  machines = {
  };
}
