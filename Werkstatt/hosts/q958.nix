# [META] ID: NIXH-SYS-043 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Host Configuration: Fujitsu Q958 ---
 * Aviation-Grade Home Server | Single Source of Truth
 */
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # 🚀 DIE EXPLIZITE AKTIVIERUNG (God-Mode Control)
  mynixos.services = {
    # Gateway
    caddy.enable = true;

    # Media Layer
    jellyfin.enable = true;
    audiobookshelf.enable = true;
    navidrome.enable = true;
    sabnzbd.enable = true;
    
    # Infrastructure
    pocketId.enable = true;
    valkey.enable = true;
    postgresql.enable = true;
    
    # Automation
    n8n.enable = true;
  };

  # Host-spezifische Overrides
  networking.hostName = "tower";
  system.stateVersion = "25.11";
  
  # User (Moritz - Baumeister)
  users.users.moritz = {
    isNormalUser = true;
    description = "Moritz";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
    packages = with pkgs; [];
  };

  # Basic SSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = true;
  };
}
