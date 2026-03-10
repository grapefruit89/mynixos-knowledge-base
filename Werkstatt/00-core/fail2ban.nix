# [META] ID: NIXH-CORE-008 | ADR: TBD | Version: 1.0 | Stage: 1
{
  config,
  pkgs,
  lib,
  ...
}: let
  # 🚀 NMS v4.2.1 Metadaten (Aviation-Grade Upgrade)
  nms = {
    id = "NIXH-00-COR-010-UPGRADE";
    title = "Fail2ban (SRE Aggressive + Zero-Tolerance)";
    description = "Aggressive brute-force protection with specialized Caddy JSON filters and immediate 1-week ban for scanner activity.";
    layer = 00;
    nixpkgs.category = "services/security";
    capabilities = ["security/bruteforce-protection" "network/hardening" "scanner-zero-tolerance"];
    audit.last_reviewed = "2026-03-10";
    audit.complexity = 3;
  };

  sshPort = toString config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs or [];
  tailnetCidrs = config.my.configs.network.tailnetCidrs or [];
in {
  options.my.meta.fail2ban = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = lib.mkIf (config.my.services.fail2ban.enable or true) {
    services.fail2ban = {
      enable = true;
      # 🛡️ GLOBAL HARDENING
      banaction = "nftables-multiport";
      banaction-allports = "nftables-allports";
      ignoreIP = ["127.0.0.1/8" "::1"] ++ lanCidrs ++ tailnetCidrs;

      bantime = "1h";
      maxretry = 5;

      # 📈 INCREMENTAL BANNING (Aggressive)
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h"; # 1 Woche max
      };

      daemonSettings.Definition.logtarget = "SYSLOG";

      jails = {
        sshd.settings = {
          enabled = true;
          port = sshPort;
          mode = "aggressive";
        };
        # Auth-Failures (24h Ban)
        caddy-auth.settings = {
          enabled = true;
          port = "http,https";
          filter = "caddy-json";
          backend = "systemd";
          maxretry = 3;
          findtime = "5m";
          bantime = "24h";
        };
        # 🛡️ ZERO TOLERANCE SCANNER (1 Week Ban)
        caddy-scan-aggressive.settings = {
          enabled = true;
          port = "http,https";
          filter = "caddy-scan-aggressive";
          backend = "systemd";
          maxretry = 1; # ONE STRIKE AND YOU'RE OUT
          findtime = "1m";
          bantime = "168h"; # Sofort 1 Woche
        };
      };
    };

    # 🔍 CUSTOM FILTERS
    environment.etc = {
      "fail2ban/filter.d/caddy-json.conf".text = ''
        [Definition]
        failregex = ^.*"remote_ip":"<ADDR>".*"status":(401|403).*$
        journalmatch = _SYSTEMD_UNIT=caddy.service
      '';
      "fail2ban/filter.d/caddy-scan-aggressive.conf".text = ''
        [Definition]
        failregex = ^.*"remote_ip":"<ADDR>".*"uri":".*(?:/\.git|/\.env|/wp-admin|/wp-login\.php|/xmlrpc\.php|/\.well-known/security\.txt|/\.vscode|/\.idea|/\.sql|/\.tar|/\.zip)".*"status":404.*$
        journalmatch = _SYSTEMD_UNIT=caddy.service
      '';
    };

    # 🛡️ SYSTEMD SANDBOXING
    systemd.services.fail2ban.serviceConfig = {
      OOMScoreAdjust = 500;
      ProtectSystem = "strict";
      ReadWritePaths = ["/var/lib/fail2ban" "/var/run/fail2ban"];
      PrivateTmp = true;
    };
  };
}
