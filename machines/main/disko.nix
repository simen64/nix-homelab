# ---
# schema = "multi-disk-zfs"
# [placeholders]
# osDisk = "/dev/disk/by-id/ata-Crucial_CT525MX300SSD1_170115435DC9"
# nvme0 = "/dev/disk/by-id/nvme-WDS100T3X0C-00SJG0_212118802649"
# nvme1 = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M600766M"
# nvme2 = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M614121A"
# hdd = "/dev/disk/by-id/ata-ST2000DM008-2UB102_WFL755BN"
# spare0 = "/dev/disk/by-id/ata-Samsung_SSD_840_EVO_250GB_S1DBNEAD826779J"
# spare1 = "/dev/disk/by-id/ata-TOSHIBA_A100_17AB50U8KQ8U"
# ---
# This file was automatically generated!
# CHANGING this configuration requires wiping and reinstalling the machine
{
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  disko.devices = {
    disk = {
      # === OS Disk: Crucial 525GB SATA SSD ===
      main = {
        name = "main-873db24934e14d329875fefa6140f2eb";
        device = "/dev/disk/by-id/ata-Crucial_CT525MX300SSD1_170115435DC9";
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
                mountOptions = ["umask=0077"];
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

      # === 3x 1TB NVMe drives for RAIDZ1 (photos/videos) ===
      nvme0 = {
        name = "nvme0-wds100t";
        device = "/dev/disk/by-id/nvme-WDS100T3X0C-00SJG0_212118802649";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zmedia";
              };
            };
          };
        };
      };
      nvme1 = {
        name = "nvme1-970evo-766m";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M600766M";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zmedia";
              };
            };
          };
        };
      };
      nvme2 = {
        name = "nvme2-970evo-121a";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0M614121A";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zmedia";
              };
            };
          };
        };
      };

      # === 2TB HDD for files ===
      hdd = {
        name = "hdd-st2000dm";
        device = "/dev/disk/by-id/ata-ST2000DM008-2UB102_WFL755BN";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zdata";
              };
            };
          };
        };
      };

      # === Spare SSDs (pooled together for future use) ===
      spare0 = {
        name = "spare0-840evo";
        device = "/dev/disk/by-id/ata-Samsung_SSD_840_EVO_250GB_S1DBNEAD826779J";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zspare";
              };
            };
          };
        };
      };
      spare1 = {
        name = "spare1-toshiba-a100";
        device = "/dev/disk/by-id/ata-TOSHIBA_A100_17AB50U8KQ8U";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zspare";
              };
            };
          };
        };
      };
    };

    # === ZFS Pools ===
    zpool = {
      # OS Pool (single disk)
      zroot = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          canmount = "off";
          mountpoint = "none";
        };
        options = {
          ashift = "12";
          autotrim = "on";
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
          "reserved" = {
            type = "zfs_fs";
            options = {
              canmount = "off";
              mountpoint = "none";
              reservation = "10G";
            };
          };
        };
      };

      # Media Pool (RAIDZ1 across 3 NVMe drives)
      zmedia = {
        type = "zpool";
        mode = "raidz1";
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
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          "media" = {
            type = "zfs_fs";
            mountpoint = "/media";
            options.mountpoint = "legacy";
          };
        };
      };

      # Data Pool (single 2TB HDD)
      zdata = {
        type = "zpool";
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
        options = {
          ashift = "12";
        };
        datasets = {
          "files" = {
            type = "zfs_fs";
            mountpoint = "/files";
            options.mountpoint = "legacy";
          };
        };
      };

      # Spare Pool (2 SATA SSDs striped — ~490GB usable)
      zspare = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          canmount = "off";
          mountpoint = "none";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };
        datasets = {
          "spare" = {
            type = "zfs_fs";
            mountpoint = "/spare";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
