# [META] ID: NIXH-HOST-001
# [META] TITLE: Generic Intel 9th Gen Hardware Profile
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-040]

{ config, lib, pkgs, ... }:

{
  # ── CPU & GPU ────────────────────────────────────────────────────────────
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  boot.initrd.kernelModules = [ "i915" ];

  # ── KERNEL RAM-BUFFER (SSD-PROTECT) ──────────────────────────────────────
  # [ADR-012] Massive RAM write cache to reduce SSD wear
  boot.kernel.sysctl = {
    "vm.dirty_bytes" = 1073741824; # 1GB Write Buffer
    "vm.dirty_background_bytes" = 536870912; # 512MB Start Background Flush
    "vm.dirty_expire_centisecs" = 3000; # 30s RAM Persistence
  };

  # ── TELEMETRY & LOGGING (BLACKBOX) ───────────────────────────────────────
  services.cockpit = {
    enable = true;
    port = 9090;
  };

  services.journald.extraConfig = ''
    RateLimitIntervalSec=0
    Storage=persistent
  '';

  # ── ESSENTIAL TOOLS ──────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    fatrace
    iotop-c
    pciutils
    usbutils
    htop
  ];

  # ── NIX SETTINGS ─────────────────────────────────────────────────────────
  nix.settings.max-jobs = lib.mkDefault 4;
}
