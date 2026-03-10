# [META] ID: NIXH-CORE-005
# [META] TITLE: Network & Firewall Foundation
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-005, ADR-040]

{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "nixhome";
    useDHCP = lib.mkDefault true;

    # ── FIREWALL (nftables Standard) ──────────────────────────────────────
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
      
      # [ADR-005] Essential Ingress Ports
      allowedTCPPorts = [ 
        22    # Standard SSH (Hardened in ssh.nix)
        80    # HTTP (Caddy Redirect)
        443   # HTTPS (Caddy)
      ];
      
      allowedUDPPorts = [ 
        41641 # Tailscale Default Port
      ];
    };

    # ── DOMAIN & DNS ───────────────────────────────────────────────────────
    # Local resolution via AdGuardHome (if enabled)
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # ── SATELLITE (ADR-040): VPN Kill-Switch Logic ──────────────────────────
  # This module prepares the foundation for vpn-confinement.nix.
  # Explicit drop policies are enforced via nftables.
}
