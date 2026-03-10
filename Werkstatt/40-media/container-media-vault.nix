# [META] ID: NIXH-MEDIA-002 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
in
{
  # [ADR-037]: The Media Vault Container
  containers.media-vault = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.200.1.1";
    localAddress = "10.200.1.2";
    
    # [KILLSWITCH]: Dieses Interface wird exklusiv für diesen Container reserviert.
    interfaces = [ "wg-privado" ];

    # Bind-Mounts für Persistenz, Medien und HARDWARE
    bindMounts = {
      "/var/lib/prowlarr" = { hostPath = "/var/lib/prowlarr"; isReadOnly = false; };
      "/var/lib/jellyfin" = { hostPath = "/var/lib/jellyfin"; isReadOnly = false; };
      "/var/lib/audiobookshelf" = { hostPath = "/var/lib/audiobookshelf"; isReadOnly = false; };
      "/mnt/media" = { hostPath = "/mnt/media"; isReadOnly = true; }; # Das Aquarium (RO)
      "/run/secrets" = { hostPath = "/run/secrets"; isReadOnly = true; };
      "/dev/dri" = { hostPath = "/dev/dri"; isReadOnly = false; }; # QuickSync Passthrough
    };

    config = { config, pkgs, ... }: {
      services.prowlarr.enable = true;
      services.jellyfin.enable = true;
      services.audiobookshelf.enable = true;
      
      # QuickSync Treiber im Container
      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.intel-media-driver ];
      };

      # [ADR-034]: API-Keys werden hier ebenfalls injiziert (Template-Basis)
      # ... (Logik wie zuvor)

      # 🛡️ NETZWERK-SOUVERÄNITÄT (Killswitch)
      networking.useDHCP = false;
      networking.defaultGateway = "10.2.0.1"; # Standard Privado Gateway IP
      networking.nameservers = [ "1.1.1.1" ]; # Cloudflare DNS über VPN

      networking.firewall.enable = false; # Container-intern sicher
      system.stateVersion = "25.11";
    };
  };

  # Reverse Proxy vom Host in den Container (Zimmer-Türsteher)
  services.caddy.virtualHosts = {
    "prowlarr.${domain}".extraConfig = "import sso_auth\nreverse_proxy 10.200.1.2:9696";
    "sonarr.${domain}".extraConfig = "import sso_auth\nreverse_proxy 10.200.1.2:8989";
    "radarr.${domain}".extraConfig = "import sso_auth\nreverse_proxy 10.200.1.2:7878";
    "jellyfin.${domain}".extraConfig = "import sso_auth\nreverse_proxy 10.200.1.2:8096";
    "abs.${domain}".extraConfig = "import sso_auth\nreverse_proxy 10.200.1.2:8000";
  };
}
