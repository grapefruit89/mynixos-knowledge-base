# [META] ID: NIXH-HOST-001
# [META] TITLE: Capped Intel Hardware Profile (v14.2)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.2
# [META] REQ_REFS: [ADR-040, ADR-012]

{ config, lib, pkgs, ... }:

let
  usbIndexer = pkgs.writePython3Bin "nixh-index-usb" {
    libraries = with pkgs.python3Packages; [ redis ];
  } ''
    import os, sys, sqlite3, redis, time
    label = sys.argv[1]
    mount_path = f"/mnt/transient/{label}"
    db_path = "/persist/metadata/usb.db"
    time.sleep(2)
    if not os.path.ismount(mount_path): sys.exit(0)
    os.makedirs("/persist/metadata", exist_ok=True)
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS files (path TEXT, label TEXT)")
    cur.execute("DELETE FROM files WHERE label = ?", (label,))
    r = redis.Redis(host='localhost', port=6379, db=0)
    for root, dirs, files in os.walk(mount_path):
        for file in files:
            full_path = os.path.join(root, file)
            cur.execute("INSERT INTO files VALUES (?, ?)", (full_path, label))
            r.set(f"usb:map:{file}", full_path)
    conn.commit()
    conn.close()
  '';
in
{
  # ── KERNEL CAPPED BUFFER (SSD-PROTECT) ───────────────────────────────────
  # [ADR-012] Fixed 512MB RAM Write Buffer
  boot.kernel.sysctl = {
    "vm.dirty_bytes" = 536870912; # 512MB
    "vm.dirty_background_bytes" = 268435456; # 256MB
    "vm.dirty_expire_centisecs" = 3000;
  };

  # ── MONITORING & TOOLS ───────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    fatrace
    iotop-c
    usbIndexer
    sqlite
  ];

  systemd.services."nixh-usb-indexer@" = {
    description = "Metadata Indexer for USB Label %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${usbIndexer}/bin/nixh-index-usb %i";
      User = "root";
    };
  };

  environment.shellAliases = {
    nixh-disk-spy = "sudo fatrace -f W";
    nixh-io-top = "sudo iotop-c -o -P";
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  boot.initrd.kernelModules = [ "i915" ];
  nix.settings.max-jobs = lib.mkDefault 4;
}
