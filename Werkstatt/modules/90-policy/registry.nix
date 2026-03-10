# [META] ID: NIXH-SYS-060 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Registry (v3.0 - Strict Inversion) ---
 * All consumer-grade services are DISABLED by default.
 */
{ lib, ... }:

with lib;
{
  options.mynixos = {
    services = {
      jellyfin.enable = mkEnableOption "Jellyfin Media Server";
      audiobookshelf.enable = mkEnableOption "Audiobookshelf";
      navidrome.enable = mkEnableOption "Navidrome Music";
      sabnzbd.enable = mkEnableOption "SABnzbd Downloader";
      sonarr.enable = mkEnableOption "Sonarr TV";
      radarr.enable = mkEnableOption "Radarr Movies";
      prowlarr.enable = mkEnableOption "Prowlarr Indexer";
      n8n.enable = mkEnableOption "n8n Automation";
      pocketId.enable = mkEnableOption "PocketID (Identity)";
      valkey.enable = mkEnableOption "Valkey (KV Store)";
      postgresql.enable = mkEnableOption "PostgreSQL Cluster";
      caddy.enable = mkEnableOption "Caddy Gateway";
    };
    
    caddy = {
      snippets = mkOption {
        type = types.attrsOf types.unspecified;
        default = {};
      };
    };

    hal = {
      storage = {
        tA-nvme = mkOption { type = types.str; default = "/persist/tA-nvme"; };
        tB-ssd = mkOption { type = types.str; default = "/persist/tB-ssd"; };
        tC-bulk = mkOption { type = types.str; default = "/persist/tC-bulk"; };
      };
    };
  };
}
