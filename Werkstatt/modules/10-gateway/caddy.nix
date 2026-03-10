# [META] ID: NIXH-SYS-053 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * ID: NIXH-10-GAT-001 | Status: ACTIVE-GodMode
 * Title: Caddy Gateway (v2 - External Config)
 */
{ config, lib, pkgs, ... }:

let
  cfg = config.mynixos.services.caddy;
in
{
  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      user = "caddy";
      group = "caddy";
      # Gold-Standard: Importiere eine dedizierte, saubere Caddyfile
      configFile = ./caddy-config.Caddyfile;
    };
  };
}
