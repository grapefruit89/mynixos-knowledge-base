# [META] ID: NIXH-CORE-025 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
{
  # [MEILENSTEIN 3]: Impermanence & Sovereign Persistence
  # ID: [NIXH-00-COR-040] | Status: PROPOSED | Stand: 10.03.2026

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # ── SYSTEM CORE ──────────────────────────────────────────────────────
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/ssh" # SSH Host Keys
      "/etc/nixos" # Deine Werkstatt selbst (Souveränität!)

      # ── IDENTITY & SECRETS ───────────────────────────────────────────────
      "/var/lib/pocket-id"
      "/var/lib/sops-nix"
      "/persist/secrets" # Age Master Keys

      # ── INFRASTRUCTURE ───────────────────────────────────────────────────
      "/var/lib/tailscale"
      "/var/lib/adguardhome"
      "/var/lib/postgresql"
      "/var/lib/redis-valkey"

      # ── MEDIA STACK ──────────────────────────────────────────────────────
      "/var/lib/sonarr"
      "/var/lib/radarr"
      "/var/lib/prowlarr"
      "/var/lib/jellyfin"
      "/var/lib/sabnzbd"
      "/var/lib/audiobookshelf"
      "/var/lib/navidrome"

      # ── KNOWLEDGE & APPS ─────────────────────────────────────────────────
      "/var/lib/paperless"
      "/var/lib/miniflux"
      "/var/lib/readeck"
      "/var/lib/vaultwarden"
      "/var/lib/n8n"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
