# [META] ID: NIXH-GATE-002
# [META] TITLE: Caddy Ingress (M1-Abrams)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-005, ADR-031]

{ config, lib, pkgs, ... }:

{
  services.caddy = {
    enable = true;
    
    # ── GLOBAL SETTINGS ───────────────────────────────────────────────────
    globalConfig = ''
      admin off
      auto_https off
      servers {
        trusted_proxies static private_ranges
      }
    '';

    # ── VIRTUAL HOSTS ─────────────────────────────────────────────────────
    # Standard Landing Page & SSO Entry
    virtualHosts."auth.nixhome.local" = {
      extraConfig = ''
        # [UDS-MANDAT] Kommunikation mit Pocket-ID via Socket
        reverse_proxy unix//run/pocket-id/pocket-id.sock
        
        header {
          X-Content-Type-Options nosniff
          X-Frame-Options DENY
          Referrer-Policy no-referrer-when-downgrade
        }
      '';
    };
  };

  # ── HARDENING (Aviation-Grade) ──────────────────────────────────────────
  systemd.services.caddy = {
    serviceConfig = {
      # Caddy needs access to the Pocket-ID socket
      SupplementaryGroups = [ "pocket-id" ];
      
      # Sandboxing
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      
      # Runtime Directory for UDS
      RuntimeDirectory = "caddy";
      RuntimeDirectoryMode = "0750";
    };
  };

  # Port-Freigabe (Sicherheit durch NIXH-CORE-005 bereits abgedeckt)
}
