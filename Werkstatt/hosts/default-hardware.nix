# [META] ID: NIXH-HOST-001
# [META] TITLE: Generic Intel Hardware Profile (Mini-PC)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-040]

{ config, lib, pkgs, ... }:

{
  # ── CPU & MICROCODE ──────────────────────────────────────────────────────
  hardware.cpu.intel.updateMicrocode = true;
  
  # ── GPU (Intel i915) ─────────────────────────────────────────────────────
  # Generic tuning for Intel 8th/9th Gen (Coffee Lake)
  boot.initrd.kernelModules = [ "i915" ];

  # ── ESSENTIAL FIRMWARE ───────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # ── SYSTEM-SPECIFIC ──────────────────────────────────────────────────────
  # For Mini-PC Power Management (Fujitsu, Dell, HP)
  powerManagement.enable = true;
  
  # Optimized for 4-Core Systems (i3-9100/i5-6500)
  nix.settings.max-jobs = lib.mkDefault 4;
}
