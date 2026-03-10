# [META] ID: NIXH-CORE-010 | ADR: TBD | Version: 1.0 | Stage: 1
{ lib, ... }: {
  options.my.services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Service Aktivierung";
      };
    });
    default = {};
    description = "Zentrales Register für alle MyNixOS Dienste.";
  };
}
