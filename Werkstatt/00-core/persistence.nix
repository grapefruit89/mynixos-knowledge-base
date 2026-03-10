# [META] ID: NIXH-CORE-003
# [META] TITLE: Impermanence Strategy (Persistence)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-010, ADR-033]

{ config, lib, pkgs, ... }:

{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # ── SYSTEM CORE ──────────────────────────────────────────────────────
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/nixos" # [ADR-032] Local Mirroring / Workshop
      "/etc/ssh" # Host Identity

      # ── IDENTITY & SECRETS ───────────────────────────────────────────────
      "/var/lib/pocket-id"
      "/var/lib/sops-nix"
      
      # ── INFRASTRUCTURE ───────────────────────────────────────────────────
      "/var/lib/tailscale"
      "/var/lib/adguardhome"
      "/var/lib/postgresql"
      "/var/lib/redis-valkey"

      # ── SERVICES & APPS ──────────────────────────────────────────────────
      "/var/lib/sonarr"
      "/var/lib/radarr"
      "/var/lib/prowlarr"
      "/var/lib/jellyfin"
      "/var/lib/audiobookshelf"
      "/var/lib/paperless"
      "/var/lib/vaultwarden"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # ── SATELLITE (ADR-033): Root-on-tmpfs Warning ──────────────────────────
  # This module assumes that / is mounted as tmpfs.
  # Ensure the mount point /persist exists on the DISK_SYSTEM.
}
