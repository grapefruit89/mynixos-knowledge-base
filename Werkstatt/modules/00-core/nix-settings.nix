# [META] ID: NIXH-SYS-049 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Nix Settings (Aviation-Grade Purity) ---
 * Optimizes the Nix engine and allows unfree packages for Media-Stack.
 */
{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    warn-dirty = false;
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
