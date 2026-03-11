# [META] ID: NIXH-HOST-001
# [META] TITLE: Generic Intel 9th Gen Hardware Profile (Elastic)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-040, ADR-012]

{ config, lib, pkgs, ... }:

let
  # 🔍 SRE-Tool: Intelligent USB Indexer
  usbIndexer = pkgs.writePython3Bin "nixh-index-usb" {
    libraries = with pkgs.python3Packages; [ redis ];
  } ''
    import os
    import sys
    import sqlite3
    import redis
    import time

    label = sys.argv[1]
    mount_path = f"/mnt/transient/{label}"
    db_path = "/persist/metadata/usb.db"
    
    # Wait for mount
    time.sleep(2)
    if not os.path.ismount(mount_path):
        sys.exit(0)

    # SQLite Persistence
    os.makedirs("/persist/metadata", exist_ok=True)
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS files (path TEXT, label TEXT)")
    cur.execute("DELETE FROM files WHERE label = ?", (label,))

    # Valkey Cache
    r = redis.Redis(host='localhost', port=6379, db=0)

    print(f"Indexing {label}...")
    for root, dirs, files in os.walk(mount_path):
        for file in files:
            full_path = os.path.join(root, file)
            cur.execute("INSERT INTO files VALUES (?, ?)", (full_path, label))
            r.set(f"usb:map:{file}", full_path)

    conn.commit()
    conn.close()
    print("Indexing complete.")
  '';
in
{
  # ── KERNEL ELASTIC BUFFER (SSD-PROTECT) ──────────────────────────────────
  # [ADR-012] 20% RAM Write Buffer for high-speed downloads
  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 20;
    "vm.dirty_background_ratio" = 10;
    "vm.dirty_expire_centisecs" = 3000;
  };

  # ── VALKEY CACHE (Tier 0.5) ──────────────────────────────────────────────
  services.redis.servers."main" = {
    settings = {
      maxmemory = "512mb";
      maxmemory-policy = "allkeys-lru";
    };
  };

  # ── MONITORING & INDEXING TOOLS ──────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    fatrace
    iotop-c
    usbIndexer
    sqlite
  ];

  # ── SRE SYSTEMD SERVICES ─────────────────────────────────────────────────
  systemd.services."nixh-usb-indexer@" = {
    description = "Metadata Indexer for USB Label %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${usbIndexer}/bin/nixh-index-usb %i";
      User = "root";
    };
  };

  # ── ALIASES & SPY ────────────────────────────────────────────────────────
  environment.shellAliases = {
    nixh-disk-spy = "sudo fatrace -f W";
    nixh-io-top = "sudo iotop-c -o -P";
  };

  # ── GENERIC HARDWARE BASE ────────────────────────────────────────────────
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  boot.initrd.kernelModules = [ "i915" ];
  nix.settings.max-jobs = lib.mkDefault 4;
}
