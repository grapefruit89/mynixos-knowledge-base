# [META] ID: NIXH-CORE-002
# [META] TITLE: System Core Settings
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-032, ADR-040]

{ config, lib, pkgs, ... }:

{
  nix = {
    # ── SETTINGS (Aviation-Grade Performance) ──────────────────────────────
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      max-jobs = 4; # Fully utilize i3-9100
      cores = 4;
      trusted-users = [ "root" "@wheel" ];
      
      # [ADR-032] Sovereign Mirroring Preparation
      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    # ── GARBAGE COLLECTION (Maintenance) ────────────────────────────────────
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # ── SYSTEM CORE (ISO-Standard) ───────────────────────────────────────────
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  
  # Allow unfree packages (Standard for Homelab)
  nixpkgs.config.allowUnfree = true;

  # Essential System Packages (Core only)
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    pciutils
    usbutils
  ];

  system.stateVersion = "25.11";
}
