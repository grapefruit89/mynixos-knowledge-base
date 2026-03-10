# [META] ID: NIXH-SYS-045 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Disko Layout (v4.3 - BTRFS Persistence) ---
 * High-End Purity Layout based on Misterio77.
 */
{ lib, ... }:

{
  disko.devices.disk.nvme = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            fs-type = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/root" = { mountpoint = "/"; };
              "/blank" = { }; 
              "/nix" = { mountpoint = "/nix"; mountOptions = [ "compress=zstd" "noatime" ]; };
              "/persist" = { mountpoint = "/persist"; mountOptions = [ "compress=zstd" ]; };
            };
          };
        };
      };
    };
  };
}
