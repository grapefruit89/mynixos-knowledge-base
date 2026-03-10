# [META] ID: NIXH-SYS-028 | ADR: TBD | Version: 1.0 | Stage: 1
{
  config,
  pkgs,
  lib,
  ...
}: let
  nms = {
    id = "NIXH-60-APP-021";
    title = "FileBrowser (Go-Minimal UI)";
    description = "Ultra-lean file management UI in a single Go binary.";
    layer = 60;
    nixpkgs.category = "services/web-apps";
    capabilities = ["file-management" "web-ui" "go-native"];
    audit.last_reviewed = "2026-03-10";
  };
  
  cfg = config.my.services.filebrowser;
  domain = "files.${config.my.configs.network.domain or "home.local"}";
in {
  options.my.services.filebrowser = {
    enable = lib.mkEnableOption "FileBrowser Service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Internal HTTP Port for FileBrowser";
    };
    rootPath = lib.mkOption {
      type = lib.types.path;
      default = "/";
      description = "The root directory FileBrowser should show.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Systemd Service (da oft kein natives NixOS Modul existiert)
    systemd.services.filebrowser = {
      description = "FileBrowser Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${pkgs.filebrowser}/bin/filebrowser --port ${toString cfg.port} --address 127.0.0.1 --root ${cfg.rootPath} --database /var/lib/filebrowser/filebrowser.db";
        Restart = "always";
        User = "filebrowser";
        Group = "filebrowser";
        StateDirectory = "filebrowser";
        # Sandboxing
        ProtectSystem = "full";
        NoNewPrivileges = true;
      };
    };

    users.users.filebrowser = {
      isSystemUser = true;
      group = "filebrowser";
    };
    users.groups.filebrowser = {};

    # 🌐 CADDY INGRESS
    services.caddy.virtualHosts."${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
        encode zstd gzip
        header {
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        }
      '';
    };
  };
}
