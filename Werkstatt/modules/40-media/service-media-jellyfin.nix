# [META] ID: NIXH-SYS-056 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * ID: NIXH-40-MED-007 | Status: ACTIVE-GodMode
 * Title: Hardened Jellyfin (Aviation-Grade GPU Sandbox)
 */
{ config, lib, pkgs, ... }:

let
  cfg = config.mynixos.services.jellyfin;
  # SRE: Offiziellen API-Call aus der `nlib` Bibliothek nutzen
  mkPath = config.lib.flake.storage.mkPath;
in
{
  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      dataDir = mkPath "NIXH-40-MED-007" "tA-nvme";
    };

    # SRE Tor 4: Hardening with GPU BindPaths
    systemd.services.jellyfin.serviceConfig = {
      # 1. GPU Passthrough into Private Sandbox
      DeviceAllow = [ "/dev/dri/renderD128 rw" ];
      BindPaths = [ "/dev/dri/renderD128" ];
      
      # 2. Strict Sandboxing
      PrivateDevices = true;
      ProtectSystem = lib.mkForce "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = [ "" ];
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      
      # 3. Performance (A/V Law)
      Nice = -10;
      CPUWeight = 1000;
      IOWeight = 1000;
    };
  };
}
