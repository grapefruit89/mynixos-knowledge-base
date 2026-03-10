# [META] ID: NIXH-SYS-046 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Storage Broker (Aviation-Grade HAL) ---
 * Implements the ABC-Tiering logic from ADR-006.
 */
{ config, lib, pkgs, ... }:

let
  cfg = config.mynixos.hal.storage;
in
{
  config = {
    # Automatisches Anlegen der Basis-Verzeichnisse
    systemd.tmpfiles.rules = [
      "d /persist 0755 root root -"
      "d ${cfg.tA-nvme} 0755 root root -"
      "d ${cfg.tB-ssd} 0755 root root -"
      "d ${cfg.tC-bulk} 0755 root root -"
    ];
  };
}
