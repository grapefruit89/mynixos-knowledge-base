# [META] ID: NIXH-SYS-034 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
{
  # [ADR-022]: Gatus Declarative Monitoring
  services.gatus = {
    enable = true;
    settings = {
      endpoints = [
        {
          name = "Local Gateway";
          url = "http://127.0.0.1:${toString config.my.ports.adguard}";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Forgejo (Git)";
          url = "http://127.0.0.1:${toString config.my.ports.forgejo}";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Conduit (Matrix)";
          url = "http://127.0.0.1:${toString config.my.ports.matrix}/_matrix/client/versions";
          interval = "1m";
          conditions = [ "[STATUS] == 200" ];
        }
        {
          name = "Valkey (Cache)";
          url = "tcp://127.0.0.1:${toString config.my.ports.valkey}";
          interval = "1m";
          conditions = [ "[CONNECTED] == true" ];
        }
        {
          name = "Whisper STT (API)";
          url = "http://127.0.0.1:${toString config.my.ports.whisper}/health";
          interval = "5m";
          conditions = [ "[STATUS] == 200" ];
        }
      ];
    };
  };
}
