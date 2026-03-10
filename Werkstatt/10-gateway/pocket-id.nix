# [META] ID: NIXH-GATE-010
# [META] TITLE: Pocket-ID (Sovereign Identity)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-001, ADR-005]

{ config, lib, pkgs, ... }:

{
  services.pocket-id = {
    enable = true;
    
    # ── PERSISTENCE (ADR-010) ──────────────────────────────────────────────
    # Data is kept on /persist via NIXH-CORE-003
    dataDir = "/var/lib/pocket-id";
    
    settings = {
      # Sovereign Identity Issuer
      issuer = "https://auth.nixhome.local";
      public_registration = false; # [ADR-001] Restricted Access
      
      # Use localhost only for now (UDS proxy via socat if needed)
      # [NOTE] To bridge to Caddy UDS: 
      # services.pocket-id.settings.listen_addr = "127.0.0.1:port";
    };
  };

  # ── HARDENING (Aviation-Grade) ──────────────────────────────────────────
  systemd.services.pocket-id = {
    serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      RuntimeDirectory = "pocket-id";
      RuntimeDirectoryMode = "0750";
    };
  };

  # Dependency: Requires Caddy as reverse proxy
}
