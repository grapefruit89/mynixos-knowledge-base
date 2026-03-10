# [META] ID: NIXH-CORE-038 | ADR: TBD | Version: 1.0 | Stage: 1
{
  config,
  pkgs,
  lib,
  ...
}: let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-036";
    title = "Tty Info";
    description = "Service to display critical system information like IP addresses on the physical console (TTY1).";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["system/observability" "hardware/console-info"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in {
  options.my.meta.tty_info = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for tty-info module";
  };

  config = {
    systemd.services.tty-ip-info = {
      description = "Display IP Address on TTY1";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
      };
      script = ''
        sleep 2
        echo -e "\n\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\033[1;32m🌐 NIXHOME SYSTEM STATUS\033[0m"
        echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\n\033[1;34m📍 IPv4 Adressen:\033[0m"
        ${pkgs.iproute2}/bin/ip -4 -o addr show | ${pkgs.gnugrep}/bin/grep -v 'lo' | ${pkgs.gawk}/bin/awk '{print "   • " $2 ": " $4}' | ${pkgs.gnused}/bin/sed 's|/[0-9]*||'
        echo -e "\n\033[1;34m🔗 Lokale URLs:\033[0m"
        echo -e "   • http://nixhome.local\n   • http://10.254.0.1 (Notfall-Anker)\n   • http://$(hostname).local"
        echo -e "\n\033[1;33m🛠  SSH Zugang:\033[0m"
        echo -e "   ssh ${config.my.configs.identity.user}@10.254.0.1 -p ${toString config.my.ports.ssh}"
        echo -e "\n\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
      '';
    };
  };
}
