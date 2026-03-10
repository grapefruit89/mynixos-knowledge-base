# [META] ID: NIXH-SYS-030 | ADR: TBD | Version: 1.0 | Stage: 1
{
  config,
  pkgs,
  lib,
  ...
}: let
  nms = {
    id = "NIXH-60-APP-020";
    title = "SFTPGo (Go-Native Storage)";
    description = "Aviation-grade SFTP/HTTP/WebDAV server with Web-UI and Cloud-Backends.";
    layer = 60;
    nixpkgs.category = "services/networking";
    capabilities = ["file-transfer" "webdav" "sftp" "s3-backend"];
    audit.last_reviewed = "2026-03-10";
  };
  
  cfg = config.my.services.sftpgo;
  domain = "sftp.${config.my.configs.network.domain or "home.local"}";
in {
  options.my.services.sftpgo = {
    enable = lib.mkEnableOption "SFTPGo Service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Internal HTTP Port for SFTPGo Web UI";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sftpgo = {
      enable = true;
      settings = {
        httpd = {
          bindings = [{
            port = cfg.port;
            address = "127.0.0.1";
            enable_web_admin = true;
            enable_web_client = true;
          }];
        };
        # 🛡️ SECURITY FIRST
        common = {
          defender = {
            enabled = true;
            driver = "memory"; # Fail2ban backup
            ban_time = 30;
            ban_time_increment = 50;
            threshold = 10;
          };
        };
      };
    };

    # 🌐 CADDY INGRESS
    services.caddy.virtualHosts."${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
        encode zstd gzip
        header {
          Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
          X-Content-Type-Options nosniff
          X-Frame-Options DENY
          Referrer-Policy no-referrer-when-downgrade
        }
      '';
    };

    # 🧱 FIREWALL
    networking.firewall.allowedTCPPorts = [ 2022 ]; # Default SFTP Port
  };
}
