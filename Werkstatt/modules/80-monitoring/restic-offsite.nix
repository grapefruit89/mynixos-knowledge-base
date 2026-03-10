# [META] ID: NIXH-SYS-059 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Off-Site Sync (Final Hope) ---
 * High-speed sync of local Restic vault to Cloudflare R2.
 */
{ config, lib, pkgs, ... }:

{
  systemd.services.restic-offsite = {
    description = "Sync Restic Vault to Cloudflare R2";
    after = [ "restic-backups-daily.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.rclone}/bin/rclone sync /mnt/tier-a/.restic-vault r2:nixhome-vault --fast-list";
      # SRE Safety: Niedrige Priorität, um Streaming nicht zu stören
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
}