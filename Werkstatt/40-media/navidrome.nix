# [META] ID: NIXH-MEDIA-005 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
{
  # [ADR-027]: Navidrome Music Server
  services.navidrome = {
    enable = true;
    settings = {
      Address = "127.0.0.1";
      Port = config.my.ports.navidrome or 4533;
      MusicFolder = "/mnt/media/music";
      ScanSchedule = "@every 1h";
      LogLevel = "info";
    };
  };

  # Reverse Proxy
  services.caddy.virtualHosts."music.${config.my.configs.identity.domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString (config.my.ports.navidrome or 4533)}
    '';
  };
}
