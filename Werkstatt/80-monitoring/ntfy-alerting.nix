# [META] ID: NIXH-SYS-036 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
{
  # [ADR-025]: Unified SRE Alerting Backend
  # Erlaubt jedem Dienst via OnFailure einen Alarm zu senden.
  
  systemd.services."ntfy-unit-failure@" = {
    description = "Send ntfy alert for failed unit %i";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = pkgs.writeShellScript "ntfy-fail-script" ''
        UNIT_NAME="%i"
        HOSTNAME=$(hostname)
        MESSAGE="🚨 MyNixOS SRE Alarm: Service '$UNIT_NAME' auf $HOSTNAME ist abgestürzt!"
        
        # [ADR-025] Sende an lokalen ntfy-Server (Port 10015)
        ${pkgs.curl}/bin/curl \
          -d "$MESSAGE" \
          http://127.0.0.1:10015/system-alerts
      '';
    };
  };
}
