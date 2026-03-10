# [META] ID: NIXH-SYS-050 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Persistence (Blank Snapshot Strategy) ---
 * Radically cleans the system while keeping the critical state.
 */
{ config, lib, pkgs, ... }:

{
  # 1. 🧹 Der Reinigungs-Mechanismus (Boot-Phase)
  # ACHTUNG: Nur aktiv, wenn das BTRFS-Layout aus disko existiert.
  boot.initrd.postDeviceCommands = lib.mkAfter """
    mkdir -p /mnt
    mount -o subvol=/ /dev/nvme0n1p2 /mnt # Ziel-Partition anpassen
    echo \"Cleaning root subvolume...\"
    btrfs subvolume delete /mnt/root
    btrfs subvolume snapshot /mnt/blank /mnt/root
    umount /mnt
  """;

  # 2. 🛡️ Was wir EXPLICIT behalten (Opt-in)
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/home/mynixos" # Deine Config-Repo
      "/home/moritz"  # Dein User-Verzeichnis
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
