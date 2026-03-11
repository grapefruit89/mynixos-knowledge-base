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
  boot.kernelParams = [ "i915.enable_guc=3" "i915.enable_fbc=1" "i915.fastboot=1" ];

  # ── KERNEL ───────────────────────────────────────────────────────────────
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];

  # ── POWER ────────────────────────────────────────────────────────────────
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # ── TRACKING TOOLS & SPY SCRIPT ──────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    fatrace
    iotop-c
    mergerfs
    fuse
    xfsprogs
    btrfs-progs
  ];

  # [ADR-040] SRE-Tool: Festplatten-Spion
  environment.shellAliases = {
    # Zeigt live alle Schreibvorgänge auf dem Storage-Pool
    nixh-disk-spy = "sudo fatrace -f W -p /data/storage";
    # Zeigt I/O Durchsatz pro Prozess
    nixh-io-top = "sudo iotop-c -o -P";
  };

  nix.settings.max-jobs = lib.mkDefault 4;
}
