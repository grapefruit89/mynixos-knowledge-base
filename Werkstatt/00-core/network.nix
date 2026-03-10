# [META] ID: NIXH-CORE-005
# [META] TITLE: Network & Firewall (nftables)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-005, ADR-040]

{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "nixos-minimal";
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

    # DNS configuration (Local-first logic)
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

  # ── SATELLITE (ADR-040): VPN Kill-Switch Logic ──────────────────────────
  # This base configuration ensures that only explicitly allowed ports are open.
  # All other traffic is dropped by nftables default policy.
}
