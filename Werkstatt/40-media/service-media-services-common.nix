# [META] ID: NIXH-MEDIA-021 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
let
  mediaGid = 993; # Unser Standard GID-Anker
in
{
  # [ADR-038]: Platin-Hardening für Media-Services (Nixarr Logic)
  # ID: [NIXH-40-MED-010] | Status: ACTIVE | Stand: 10.03.2026

  options.my.services.media-hardening = {
    enable = lib.mkEnableOption "Platin Hardening for Media Apps";
  };

  config = lib.mkIf config.my.services.media-hardening.enable {
    # Wir erstellen die systemd-Overlays für Radarr, Sonarr, etc. (Aviation-Grade Sandboxing)
    systemd.services = {
      radarr = { serviceConfig = { 
        ProtectSystem = "strict"; 
        PrivateTmp = true; 
        NoNewPrivileges = true; 
        ProtectHome = true; 
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ReadWritePaths = [ "/var/lib/radarr" "/mnt/media" ]; 
      }; };
      sonarr = { serviceConfig = { 
        ProtectSystem = "strict"; 
        PrivateTmp = true; 
        NoNewPrivileges = true; 
        ProtectHome = true; 
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ReadWritePaths = [ "/var/lib/sonarr" "/mnt/media" ]; 
      }; };
      prowlarr = { serviceConfig = { 
        ProtectSystem = "strict"; 
        PrivateTmp = true; 
        NoNewPrivileges = true; 
        ProtectHome = true; 
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ReadWritePaths = [ "/var/lib/prowlarr" ]; 
      }; };
      jellyfin = { serviceConfig = { 
        ProtectSystem = "strict"; 
        PrivateTmp = true; 
        NoNewPrivileges = true; 
        ProtectHome = true; 
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        ReadWritePaths = [ "/var/lib/jellyfin" "/mnt/media" ]; 
      }; };
    };

    # Gemeinsame Media-Gruppe sicherstellen
    users.groups.media.gid = mediaGid;
  };
}
