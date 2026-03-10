# [META] ID: NIXH-SYS-055 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos SABnzbd Module (The Leashed Engine) ---
 * Limits resources to protect media streaming performance.
 */
{ config, lib, pkgs, ... }:

{
  services.sabnzbd.enable = true;

  systemd.services.sabnzbd.serviceConfig = {
    # Die doppelte Leine:
    CPUQuota = "50%";        # Nutzt maximal 2 Kerne (bei 4 Kernen)
    IOWeight = 10;           # Niedrigste I/O Priorität (Standard ist 100)
    Nice = 19;               # Niedrigste CPU Priorität
    IOSchedulingClass = "idle"; # Arbeitet nur, wenn sonst niemand I/O braucht
  };
}