# [META] ID: NIXH-SYS-058 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Hardware Guard (smartd & e2scrub) ---
 * Provides early warning for HDD failure and passive data integrity.
 */
{ config, lib, pkgs, ... }:

{
  services.smartd = {
    enable = true;
    notifications = {
      mail.enable = false;
      wall.enable = true; # Schreibt Warnungen direkt in alle offenen Terminals!
    };
  };

  # 
}