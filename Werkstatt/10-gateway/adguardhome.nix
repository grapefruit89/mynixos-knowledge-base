# [META] ID: NIXH-GATE-011
# [META] TITLE: AdGuardHome (DNS-Shield)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-007, ADR-040]

{ config, lib, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    
    # ── PERSISTENCE (ADR-010) ──────────────────────────────────────────────
    # Config is on /persist/var/lib/adguardhome (via NIXH-CORE-003)
    # [ADR-007] DNS Naming Standard binding
    settings = {
      http = {
        address = "127.0.0.1:3000"; # [UDS-MANDAT-EXEMPTION]: Standard Web UI
      };
      dns = {
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "https://dns.cloudflare.com/dns-query"
        ];
        bootstrap_dns = [ "9.9.9.9" "1.1.1.1" ];
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
      };
    };
  };

  # ── FIREWALL (ADR-005) ──────────────────────────────────────────────────
  networking.firewall = {
    allowedTCPPorts = [ 53 3000 ];
    allowedUDPPorts = [ 53 ];
  };
}
