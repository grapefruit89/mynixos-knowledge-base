# [META] ID: NIXH-INFRA-001
# [META] TITLE: PostgreSQL Database (Infrastructure Core)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-040, ADR-021]

{ config, lib, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    # [ADR-021] Use PostgreSQL 16 (Stable Standard for 2026)
    package = pkgs.postgresql_16;
    
    # ── PERSISTENCE (Impermanence) ──────────────────────────────────────────
    # Data is kept on /persist via NIXH-CORE-003
    dataDir = "/var/lib/postgresql/${config.services.postgresql.package.psqlSchema}";

    # ── PERFORMANCE TUNING (Q958 Optimized) ─────────────────────────────────
    settings = {
      max_connections = 100;
      shared_buffers = "512MB"; # Optimized for 16GB RAM Q958
      effective_cache_size = "1GB";
      maintenance_work_mem = "128MB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "16MB";
      default_statistics_target = 100;
      random_page_cost = 1.1; # Optimized for NVMe (DISK_SYSTEM)
      effective_io_concurrency = 200;
      work_mem = "16MB";
      min_wal_size = "1GB";
      max_wal_size = "4GB";
    };

    # ── SECURITY ───────────────────────────────────────────────────────────
    authentication = pkgs.lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            scram-sha-256
      host    all             all             ::1/128                 scram-sha-256
    '';
  };

  # ── HARDENING (Aviation-Grade) ──────────────────────────────────────────
  systemd.services.postgresql.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
  };
}
