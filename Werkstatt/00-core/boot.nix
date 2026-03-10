# [META] ID: NIXH-CORE-001
# [META] TITLE: Boot Foundation (Aviation-Grade)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-009, ADR-040]

{ config, lib, pkgs, ... }:

{
  boot = {
    # ── BOOTLOADER (ISO-Standard) ──────────────────────────────────────────
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 15; # [ADR-009] Prevention against /boot overflow
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = 3; # Aviation-Grade: Fast Recovery
    };

    # ── KERNEL & HARDWARE (Q958 Optimized) ──────────────────────────────────
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ 
      "i915.enable_guc=3" # [NUGGET] Intel 9th Gen (i3-9100) Stable GuC/HuC
      "i915.enable_fbc=1" 
      "quiet" 
      "splash"
    ];
    kernelModules = [ "kvm-intel" "i915" ];

    # ── STORAGE BINDING (ADR-040) ───────────────────────────────────────────
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      supportedFilesystems = [ "zfs" "ext4" "vfat" ];
    };
  };

  # ── CONTEXTUAL SATELLITES (Associative Mining) ──────────────────────────
  # Verknüpfung mit DISK_SYSTEM Label via fileSystems (extern deklariert)
  # Ensure microcode is active
  hardware.cpu.intel.updateMicrocode = true;
}
