# [META] ID: NIXH-INFRA-002
# [META] TITLE: Valkey (Redis Replacement)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-021, ADR-040]

{ config, lib, pkgs, ... }:

{
  services.redis.servers."main" = {
    enable = true;
    # [ADR-021] Binary Efficiency: Valkey (C-Binary) instead of Redis
    package = pkgs.valkey;
    
    # ── SETTINGS ──────────────────────────────────────────────────────────
    port = 6379;
    bind = "127.0.0.1";
    
    # ── PERSISTENCE (Impermanence) ──────────────────────────────────────────
    # State is kept on /persist/var/lib/redis-valkey (via NIXH-CORE-003)
    save = [ [ 900 1 ] [ 300 10 ] [ 60 10000 ] ];
  };

  # ── HARDENING (Aviation-Grade) ──────────────────────────────────────────
  systemd.services.redis-main.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    MemoryDenyWriteExecute = true;
  };
}
