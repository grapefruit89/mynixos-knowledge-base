# [META] ID: NIXH-SYS-020 | ADR: TBD | Version: 1.0 | Stage: 1
{
  config,
  pkgs,
  lib,
  ...
}: let
  nms = {
    id = "NIXH-60-APP-021-NATIVE";
    title = "FileBrowser (Go-Native Gold Nugget)";
    description = "Aviation-grade deployment of the Go-native FileBrowser. Pure, fast, and sandboxed.";
    layer = 60;
    nixpkgs.category = "services/web-apps";
    capabilities = ["file-management" "web-ui" "go-native" "security-hardened"];
    audit.last_reviewed = "2026-03-10";
  };
  
  cfg = config.my.services.filebrowser-native;
  domain = "files-new.${config.my.configs.network.domain or "home.local"}";
in {
  options.my.services.filebrowser-native = {
    enable = lib.mkEnableOption "FileBrowser Native Service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8085;
      description = "Internal HTTP Port for FileBrowser Native";
    };
    storagePath = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/storage";
      description = "Path to manage";
    };
  };

  config = lib.mkIf cfg.enable {
    # 🛡️ NATIVE GO SERVICE
    systemd.services.filebrowser-native = {
      description = "FileBrowser (Go-Native) Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${pkgs.filebrowser}/bin/filebrowser --port ${toString cfg.port} --address 127.0.0.1 --root ${cfg.storagePath} --database /var/lib/filebrowser-native/filebrowser.db --noauth=false";
        Restart = "always";
        User = "filebrowser-native";
        Group = "filebrowser-native";
        StateDirectory = "filebrowser-native";
        
        # 🛡️ AVIATION-GRADE SANDBOXING
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        ReadOnlyPaths = [ "/" ];
        ReadWritePaths = [ "/var/lib/filebrowser-native" cfg.storagePath ];
      };
    };

    users.users.filebrowser-native = {
      isSystemUser = true;
      group = "filebrowser-native";
    };
    users.groups.filebrowser-native = {};

    # 🌐 CADDY INGRESS
    services.caddy.virtualHosts."${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
        encode zstd gzip
        header {
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
          X-Content-Type-Options nosniff
          X-XSS-Protection "1; mode=block"
        }
      '';
    };
  };
}
