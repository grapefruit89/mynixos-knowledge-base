# [META] ID: NIXH-HOST-002
# [META] TITLE: Elastic Portable Hardware Configuration
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-012, ADR-033, ADR-040]

{ config, lib, pkgs, ... }:

{
  # ── TIER 0: ELASTIC ROOT-ON-TMPFS ────────────────────────────────────────
  # [ADR-033] Dynamic sizing: 10% of RAM, capped at 2GB for safety
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=10%" "nr_inodes=1m" "mode=755" ];
  };

  # ── INTERNAL STORAGE BINDING (LABELS) ────────────────────────────────────
  fileSystems."/nix" = {
    device = "/dev/disk/by-label/DISK_SYSTEM";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/DISK_SYSTEM";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/DISK_BOOT";
    fsType = "vfat";
  };

  fileSystems."/var/cache" = {
    device = "/dev/disk/by-label/DISK_CACHE";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" ];
  };

  # ── TIER C: MERGERFS METADATA-MAP ────────────────────────────────────────
  fileSystems."/data/storage" = {
    device = "/mnt/disk*";
    fsType = "fuse.mergerfs";
    options = [
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "moveonenospc=true"
      "category.create=mfs"
      "minfreespace=20G"
      "fsname=mergerfs_pool"
    ];
  };

  # ── TIER D: USB-TRANSIENT AUTOMOUNT ──────────────────────────────────────
  services.udev.extraRules = ''
    # Intelligent USB Automount with Sync
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
    RUN+="${pkgs.systemd}/bin/systemd-mount \
      --no-block \
      --collect \
      --automount=yes \
      --options=sync,nosuid,nodev,noexec,x-systemd.idle-timeout=300 \
      $devnode /mnt/transient/%E{ID_FS_LABEL_ENC}"
    
    # Trigger Metadata-Indexing on ADD
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
    RUN+="${pkgs.systemd}/bin/systemctl start nixh-usb-indexer@%E{ID_FS_LABEL_ENC}.service"
  '';

  boot.supportedFilesystems = [ "zfs" "btrfs" "xfs" "fuse" ];
}
