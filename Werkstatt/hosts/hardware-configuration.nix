# [META] ID: NIXH-HOST-002
# [META] TITLE: Portable disko Layout (ABC-Tiering)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-012, ADR-040]

{ lib, ... }:

{
  disko.devices = {
    # --- TIER A: HOT STORAGE (DISK_SYSTEM) ---
    disk.system = {
      type = "disk";
      device = "/dev/disk/by-label/DISK_SYSTEM";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
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

    zpool.zroot = {
      type = "zpool";
      rootFsOptions = {
        compression = "lz4";
        atime = "off";
      };
      # [ADR-012] Hot Tier Performance Tuning for Databases
      datasets = {
        "root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options.recordsize = "16k";
        };
        "persist" = {
          type = "zfs_fs";
          mountpoint = "/persist";
          options.recordsize = "128k";
        };
      };
    };

    # --- TIER B: WARM STORAGE (DISK_CACHE) ---
    disk.cache = {
      type = "disk";
      device = "/dev/disk/by-label/DISK_CACHE";
      content = {
        type = "gpt";
        partitions.cache = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "btrfs";
            mountOptions = [ "compress=zstd" "noatime" ];
            mountpoint = "/var/cache";
          };
        };
      };
    };
  };
}
