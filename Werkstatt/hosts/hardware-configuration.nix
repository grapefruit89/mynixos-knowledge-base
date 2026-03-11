# [META] ID: NIXH-HOST-002
# [META] TITLE: Capped Hardware Configuration (v14.2)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.2
# [META] REQ_REFS: [ADR-012, ADR-033, ADR-040]

{ config, lib, pkgs, ... }:

{
  # ── TIER 0: CAPPED ROOT-ON-TMPFS ─────────────────────────────────────────
  # [ADR-033] Fixed 1GB limit for structural efficiency
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=1G" "mode=755" ];
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
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
    RUN+="${pkgs.systemd}/bin/systemd-mount \
      --no-block \
      --collect \
      --automount=yes \
      --options=sync,nosuid,nodev,noexec,x-systemd.idle-timeout=300 \
      $devnode /mnt/transient/%E{ID_FS_LABEL_ENC}"
    
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
    RUN+="${pkgs.systemd}/bin/systemctl start nixh-usb-indexer@%E{ID_FS_LABEL_ENC}.service"
  '';

  boot.supportedFilesystems = [ "zfs" "btrfs" "xfs" "fuse" ];
}
