# [META] ID: NIXH-HOST-001
# [META] TITLE: Generic Intel 9th Gen Hardware Profile
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-040]

{ config, lib, pkgs, ... }:

{
  # ── CPU & MICROCODE ──────────────────────────────────────────────────────
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # ── GPU (Intel i915) ─────────────────────────────────────────────────────
  # Optimized for Coffee Lake / Whiskey Lake (i3-9100)
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [ 
    "i915.enable_guc=3" 
    "i915.enable_fbc=1" 
    "i915.fastboot=1"
  ];

  # ── KERNEL MODULES (Mini-PC Essentials) ──────────────────────────────────
  boot.initrd.availableKernelModules = [ 
    "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" 
  ];

  # ── POWER MANAGEMENT ─────────────────────────────────────────────────────
  # Optimized for Headless Homelab Server
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  
  # ── NIX SETTINGS ─────────────────────────────────────────────────────────
  # Assuming 4 Cores for typical Q958/OptiPlex builds
  nix.settings.max-jobs = lib.mkDefault 4;
}
