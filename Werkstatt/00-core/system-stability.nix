# [META] ID: NIXH-CORE-037 | ADR: TBD | Version: 1.0 | Stage: 1
{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-034";
    title = "System Stability";
    description = "Proactive maintenance services to prevent NVRAM corruption and config drift.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["system/maintenance" "safety/recovery"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in {
  options.my.meta.system_stability = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for system-stability module";
  };

  config = {
    system.activationScripts.cleanEfiEntries = {
      text = ''
        echo "🧹 Bereinige verwaiste EFI-Boot-Einträge..."
        ${pkgs.efibootmgr}/bin/efibootmgr | grep "Boot[0-9]" | grep -vE "systemd-boot|NixOS|Linux|USB|Hard Drive|Network" | \
          ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.gnused}/bin/sed 's/Boot//;s/\*//' | \
          xargs -I{} ${pkgs.efibootmgr}/bin/efibootmgr -b {} -B 2>/dev/null || true
      '';
    };

    systemd.services.config-drift-detector = {
      description = "Detect configuration drift";
      after = ["nixhome-config-merger.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "oneshot";
      script = "USER_CONFIG='/var/lib/nixhome/user-config.json'; if [ -f '$USER_CONFIG' ] && [ '$(cat '$USER_CONFIG')' != '{}' ]; then echo '⚠️ HINWEIS: Das System nutzt imperative Einstellungen.'; fi";
    };

    systemd.services.nixhome-emergency = {
      description = "NixOS Home Emergency Recovery Info";
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
      };
      script = "echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n🚨 NIXHOME SETUP FEHLGESCHLAGEN\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' > /dev/tty1";
    };

    boot.kernel.sysctl = {
      # Networking-Hardening (Aviation Grade)
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Kernel-Pointer-Protection
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
    };
  };
}
