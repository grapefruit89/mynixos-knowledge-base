# [META] ID: NIXH-SYS-029 | ADR: TBD | Version: 1.0 | Stage: 1
{
  config,
  pkgs,
  lib,
  ...
}: let
  nms = {
    id = "NIXH-60-APP-022";
    title = "MicroBin (Rust Pastebin)";
    description = "Extremely fast and secure pastebin/file-share in a single Rust binary.";
    layer = 60;
    nixpkgs.category = "services/web-apps";
    capabilities = ["pastebin" "file-sharing" "rust-native" "api"];
    audit.last_reviewed = "2026-03-10";
  };
  
  cfg = config.my.services.microbin;
  domain = "bin.${config.my.configs.network.domain or "home.local"}";
in {
  options.my.services.microbin = {
    enable = lib.mkEnableOption "MicroBin Service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = "Internal HTTP Port for MicroBin";
    };
  };

  config = lib.mkIf cfg.enable {
    # NixOS hat MicroBin oft in nixpkgs
    systemd.services.microbin = {
      description = "MicroBin Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${pkgs.microbin}/bin/microbin --port ${toString cfg.port} --bind-address 127.0.0.1 --data-dir /var/lib/microbin";
        Restart = "always";
        User = "microbin";
        Group = "microbin";
        StateDirectory = "microbin";
        # Sandboxing
        ProtectSystem = "full";
        NoNewPrivileges = true;
      };
    };

    users.users.microbin = {
      isSystemUser = true;
      group = "microbin";
    };
    users.groups.microbin = {};

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
