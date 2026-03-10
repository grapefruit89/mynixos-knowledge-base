# [META] ID: NIXH-SYS-044 | ADR: TBD | Version: 1.0 | Stage: 1
{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}