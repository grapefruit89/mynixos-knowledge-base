# [META] ID: NIXH-HOST-002
# [META] TITLE: Supreme Portable Hardware Configuration
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-012, ADR-033, ADR-040]

{ config, lib, pkgs, ... }:

{
  # ── TIER 0: ROOT-ON-TMPFS (RAM-MAXIMIZATION) ─────────────────────────────
  # [ADR-033] 1GB RAM-Limit für das flüchtige Root-System
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=1G" "mode=755" ];
  };

  # ── TIER A: HOT STORAGE (DISK_SYSTEM) ────────────────────────────────────
  # Bindung ausschließlich via Label. Muss /persist und /nix bereitstellen.
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
  # Bündelt alle internen HDDs (DISK_STORAGE_*) zur 'Landkarten-Logik'
  # Erfordert: boot.supportedFilesystems = [ "fuse" ];
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
  # Dynamisches Automount für USB-Geräte nach /mnt/transient/
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", \
    RUN+="${pkgs.systemd}/bin/systemd-mount \
      --no-block \
      --collect \
      --automount=yes \
      --options=sync,nosuid,nodev,noexec,x-systemd.idle-timeout=300 \
      $devnode /mnt/transient/%E{ID_FS_LABEL_ENC}"
  '';

  # ── BUS-GUARD & SAFETY ASSERTIONS ────────────────────────────────────────
  # Verhindert, dass Tier A/B versehentlich auf dem USB-Bus landen
  system.activationScripts.storageBusGuard = {
    text = ''
      check_bus() {
        local label=$1
        local dev=$(readlink -f /dev/disk/by-label/$label)
        if [ -b "$dev" ]; then
          local bus=$(udevadm info -q path -n "$dev")
          if [[ "$bus" == *"usb"* ]]; then
            echo "🚨 CRITICAL ERROR: $label is on USB bus! System Integrity Violation (v14.0)."
            exit 1
          fi
        fi
      }
      check_bus DISK_SYSTEM
      check_bus DISK_CACHE
    '';
  };

  # ── INFRASTRUCTURE ───────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    mergerfs
    fuse
    xfsprogs
    btrfs-progs
  ];
  
  boot.supportedFilesystems = [ "zfs" "btrfs" "xfs" "fuse" ];
}
