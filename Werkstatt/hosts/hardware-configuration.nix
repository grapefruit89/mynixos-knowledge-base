# [META] ID: NIXH-HOST-002
# [META] TITLE: Intelligent Hardware & Storage Configuration
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-012, ADR-033, ADR-040]

{ config, lib, pkgs, ... }:

{
  # ── TIER 0: ROOT-ON-TMPFS & RAM-OPTIMIZATION ─────────────────────────────
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=1G" "mode=755" ];
  };

  # [ADR-012] SSD-Schonung: Aggressives Buffering im RAM
  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
    "vm.dirty_expire_centisecs" = 6000; # Daten 60s im RAM halten vor Write
    "vm.dirty_writeback_centisecs" = 500;
  };

  # ── TIER A/B: INTERNAL STORAGE (LABELS) ──────────────────────────────────
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

  # ── TIER C: COLD STORAGE (MERGERFS LANDKARTE) ─────────────────────────────
  fileSystems."/data/storage" = {
    device = "/mnt/disk*";
    fsType = "fuse.mergerfs";
    options = [
      "allow_other"
      "use_ino"
      "cache.files=partial" # Landkarten-Logik (Metadata in RAM)
      "dropcacheonclose=true"
      "moveonenospc=true"
      "category.create=mfs"
      "minfreespace=20G"
      "fsname=mergerfs_pool"
    ];
  };

  # ── TIER D: USB-TRANSIENT (AUTOMOUNT & SYNC) ──────────────────────────────
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
    RUN+="${pkgs.systemd}/bin/systemd-mount \
      --no-block \
      --collect \
      --automount=yes \
      --options=sync,nosuid,nodev,noexec,x-systemd.idle-timeout=300 \
      $devnode /mnt/transient/%E{ID_FS_LABEL_ENC}"
  '';

  # ── BUS-GUARD ────────────────────────────────────────────────────────────
  system.activationScripts.storageBusGuard = {
    text = ''
      check_bus() {
        local label=$1
        local dev=$(readlink -f /dev/disk/by-label/$label)
        if [ -b "$dev" ]; then
          local bus=$(udevadm info -q path -n "$dev")
          if [[ "$bus" == *"usb"* ]]; then
            echo "🚨 CRITICAL ERROR: $label is on USB bus! Violation of v14.0."
            exit 1
          fi
        fi
      }
      check_bus DISK_SYSTEM
      check_bus DISK_CACHE
    '';
  };

  boot.supportedFilesystems = [ "zfs" "btrfs" "xfs" "fuse" ];
}
