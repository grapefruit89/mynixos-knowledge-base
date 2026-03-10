# [META] ID: NIXH-SYS-057 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Offsite Backup (Aviation-Grade Redundancy) ---
 * Syncs the local Tier A State to a secure Cloud Backend (Backblaze/R2).
 */
{ config, lib, pkgs, ... }:

{
  # SRE Fix: Offsite Redundanz für /persist
  services.restic.backups.offsite = {
    initialize = true;
    passwordFile = config.sops.secrets."restic/offsite-pass".path;
    paths = [ "/persist" ];
    repository = "rclone:cloud-storage:mynixos-state-backup";
    
    # Ausführung alle 24h um 04:00 Uhr
    timerConfig = {
      OnCalendar = "04:00";
      RandomizedDelaySec = "1h";
    };

    # Pruning Policy (Aviation-Grade Retention)
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
}