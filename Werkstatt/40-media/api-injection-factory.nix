# [META] ID: NIXH-MEDIA-001 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
let
  # Die Fabrik-Funktion für die API-Injection
  mkKeyInjector = { serviceName, configPath, xmlPath, secretKey, user, group }: ''
    echo "🔧 Injiziere API-Key für ${serviceName}..."
    
    # 1. Key aus sops lesen
    if [ ! -f "${config.sops.secrets."${secretKey}".path}" ]; then
      echo "🚨 FEHLER: Secret ${secretKey} nicht gefunden!"
      exit 1
    fi
    WANTED_KEY=$(cat "${config.sops.secrets."${secretKey}".path}")
    
    # 2. Config-Ordner sicherstellen
    mkdir -p "$(dirname "${configPath}")"
    
    # 3. Datei initial erstellen oder Key patchen
    if [ ! -f "${configPath}" ]; then
      echo "🆕 Erstelle initiale Config für ${serviceName}..."
      echo "<Config><ApiKey>$WANTED_KEY</ApiKey></Config>" > "${configPath}"
    else
      CURRENT_KEY=$(${pkgs.xmlstarlet}/bin/xmlstarlet sel -t -v "${xmlPath}" "${configPath}" || echo "")
      if [ "$WANTED_KEY" != "$CURRENT_KEY" ]; then
        echo "🛠️  Fixe Key-Inkonsistenz in ${configPath}..."
        ${pkgs.xmlstarlet}/bin/xmlstarlet ed -u "${xmlPath}" -v "$WANTED_KEY" "${configPath}" > "${configPath}.tmp"
        mv "${configPath}.tmp" "${configPath}"
      fi
    fi
    
    # 4. Rechte sicherstellen
    chown ${user}:${group} "${configPath}"
    chmod 600 "${configPath}"
  '';
in
{
  # Wir hängen uns in die preStart Phasen der Dienste ein
  systemd.services.sonarr.preStart = lib.mkIf config.services.sonarr.enable (mkKeyInjector {
    serviceName = "Sonarr";
    configPath = "/var/lib/sonarr/config.xml";
    xmlPath = "/Config/ApiKey";
    secretKey = "sonarr_api_key";
    user = "sonarr";
    group = "sonarr";
  });

  systemd.services.radarr.preStart = lib.mkIf config.services.radarr.enable (mkKeyInjector {
    serviceName = "Radarr";
    configPath = "/var/lib/radarr/config.xml";
    xmlPath = "/Config/ApiKey";
    secretKey = "radarr_api_key";
    user = "radarr";
    group = "radarr";
  });

  systemd.services.prowlarr.preStart = lib.mkIf config.services.prowlarr.enable (mkKeyInjector {
    serviceName = "Prowlarr";
    configPath = "/var/lib/prowlarr/config.xml";
    xmlPath = "/Config/ApiKey";
    secretKey = "prowlarr_api_key";
    user = "prowlarr";
    group = "prowlarr";
  });

  environment.systemPackages = [ pkgs.xmlstarlet ];
}
