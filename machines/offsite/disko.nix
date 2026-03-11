# ---
# schema = "nvme-os-zfs-raidz-storage"
# [placeholders]
# osDisk = "/dev/disk/by-id/nvme-KBG30ZMV256G_TOSHIBA_X8FPC5HFP12P"
# storageDisk0 = "/dev/disk/by-id/ata-ST1000DM003-9YN162_S1D4SXE2"
# storageDisk1 = "/dev/disk/by-id/ata-ST1000DM003-1SB10C_Z9A0BYXX"
# storageDisk2 = "/dev/disk/by-id/ata-WDC_WD10EZEX-60WN4A0_WD-WCC6Y2YRH85T"
# ---
# This file was automatically generated!
# CHANGING this configuration requires wiping and reinstalling the machine
{

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;

  disko.devices = {
    disk = {
      # === OS Disk: NVMe 256GB ===
      main = {
        name = "main-nvme0n1";
        device = "/dev/disk/by-id/nvme-KBG30ZMV256G_TOSHIBA_X8FPC5HFP12P";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            "boot" = {
              size = "1M";
              type = "EF02"; # for grub MBR
              priority = 1;
            };
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };

      # === Storage disks: 3x 1TB SATA HDDs for RAIDZ1 ===
      storage0 = {
        name = "storage-sda";
        device = "/dev/disk/by-id/ata-ST1000DM003-9YN162_S1D4SXE2";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zstorage";
              };
            };
          };
        };
      };

      storage1 = {
        name = "storage-sdb";
        device = "/dev/disk/by-id/ata-ST1000DM003-1SB10C_Z9A0BYXX";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zstorage";
              };
            };
          };
        };
      };

      storage2 = {
        name = "storage-sdc";
        device = "/dev/disk/by-id/ata-WDC_WD10EZEX-60WN4A0_WD-WCC6Y2YRH85T";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zstorage";
              };
            };
          };
        };
      };
    };

    zpool = {
      # === OS pool (single-disk ZFS) ===
      zroot = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          canmount = "off";
          mountpoint = "none";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          "home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "true";
          };
          "var" = {
            type = "zfs_fs";
            mountpoint = "/var";
            options.mountpoint = "legacy";
          };
        };
      };

      # === Storage pool (3-disk RAIDZ1) mounted as /storage ===
      zstorage = {
        type = "zpool";
        mode = "raidz1";
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          canmount = "off";
          mountpoint = "none";
          "com.sun:auto-snapshot" = "true";
        };
        datasets = {
          "storage" = {
            type = "zfs_fs";
            mountpoint = "/storage";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
