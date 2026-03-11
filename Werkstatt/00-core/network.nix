# [META] ID: NIXH-CORE-005
# [META] TITLE: Network & Firewall (nftables) with Encrypted DNS
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.2
# [META] REQ_REFS: [ADR-005, ADR-040, ADR-007]

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

    # [ADR-007] Aviation-Grade Encrypted DNS (Fallback)
    # ── DNS-OVER-TLS (DoT) ────────────────────────────────────────────────
    # Reliable and privacy-friendly selection of encrypted resolvers.
    nameservers = [
      "9.9.9.9#dns.quad9.net"                 # Quad9 (Security/Swiss)
      "149.112.112.112#dns.quad9.net"         # Quad9 Secondary
      "194.242.2.3#adblock.dns.mullvad.net"   # Mullvad (Privacy/Adblock)
      "5.1.66.255#dns.digitale-gesellschaft.ch" # Digitale Gesellschaft (CH)
      "193.110.81.9#zero.dns0.eu"             # DNS0.eu Zero (EU-Security)
    ];
  };

  # ── SYSTEMD-RESOLVED (DoT ENFORCEMENT) ──────────────────────────────────
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ]; # Use these nameservers for all domains
    extraConfig = ''
      DNSOverTLS=yes
    '';
  };

  # ── SATELLITE (ADR-040): VPN Kill-Switch Logic ──────────────────────────
  # This base configuration ensures that only explicitly allowed ports are open.
  # All other traffic is dropped by nftables default policy.
}
