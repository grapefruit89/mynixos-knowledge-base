# [META] ID: NIXH-SYS-047 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Kernel Diet (Consumer Era v2.0) ---
 * Target: Intel 7th Gen+ / AMD Zen+ (2017-2025).
 * Ejected: Pre-2017 Legacy, Industrial, Space, Ham Radio.
 */
{ pkgs, ... }:

{
  boot.kernelPatches = [ {
    name = "consumer-era-2017-standard";
    patch = null;
    extraConfig = ''
      # Legacy / Industrial Bloat
      HAMRADIO n
      AX25 n
      CAN n
      ISDN n
      FIREWIRE n
      
      # Modern Consumer Essentials (2017+)
      NVME_CORE y
      SATA_AHCI y
      USB_XHCI_HCD y
      DRM_I915 y      # Intel 7th Gen+ Support
      DRM_AMDGPU y    # AMD Ryzen/Zen Support
    '';
  } ];
}