# [META] ID: NIXH-HOST-002
# [META] TITLE: Supreme Portable Hardware Configuration
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-012, ADR-033, ADR-040]

{ config, lib, pkgs, ... }:

{
  # ── TIER 0: ROOT-ON-TMPFS (RAM-MAXIMIZATION) ─────────────────────────────
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=1G" "mode=755" ];
  };

  # ── TIER A: HOT STORAGE (DISK_SYSTEM) ────────────────────────────────────
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

  # ── TIER B: WARM STORAGE (DISK_CACHE) ────────────────────────────────────
  fileSystems."/var/cache" = {
    device = "/dev/disk/by-label/DISK_CACHE";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" ];
  };

  # ── TIER C: COLD STORAGE (MERGERFS POOL) ──────────────────────────────────
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

  # ── TIER D: USB-TRANSIENT (ANGSTFREI-ABZIEHBAR) ──────────────────────────
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
    RUN+="${pkgs.systemd}/bin/systemd-mount \
      --no-block \
      --collect \
      --automount=yes \
      --options=sync,nosuid,nodev,noexec,x-systemd.idle-timeout=300 \
      $devnode /mnt/transient/%E{ID_FS_LABEL_ENC}"
  '';

  # ── PERSISTENT LOGS (BLACKBOX) ───────────────────────────────────────────
  # [ADR-033] Ensure logs survive root-on-tmpfs wipe
  # This mapping is handled by the impermanence module in 00-core/persistence.nix,
  # but we define the mount logic here for structural integrity.
  # environment.persistence."/persist".directories = [ "/var/log/journal" ];

  # ── INFRASTRUCTURE ───────────────────────────────────────────────────────
  boot.supportedFilesystems = [ "zfs" "btrfs" "xfs" "fuse" ];
}
