# [META] ID: NIXH-MEDIA-009 | ADR: TBD | Version: 1.0 | Stage: 1
{ lib, pkgs, config, ... }:
let
  # [ADR-041]: Automated Jellyfin Library Management (Nixflix Logic)
  # ID: [NIXH-40-MED-040] | Status: ACTIVE | Stand: 10.03.2026

  cfg = config.my.media.jellyfin;
  srePaths = config.my.configs.paths;

  # Wir definieren die Bibliotheken basierend auf aktivierten Diensten
  mkLibrary = name: type: paths: ''
    <VirtualFolder>
      <Name>${name}</Name>
      <CollectionType>${type}</CollectionType>
      <Locations>
        ${lib.concatMapStrings (path: "<string>${path}</string>") paths}
      </Locations>
    </VirtualFolder>
  '';

  libraryXml = pkgs.writeText "libraries.xml" ''
    <?xml version="1.0" encoding="utf-8"?>
    <ArrayOfVirtualFolder xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      ${lib.optionalString config.my.media.sonarr.enable (mkLibrary "TV Shows" "tvshows" [ "/mnt/media/tv" ])}
      ${lib.optionalString config.my.media.radarr.enable (mkLibrary "Movies" "movies" [ "/mnt/media/movies" ])}
      ${lib.optionalString config.my.media.audiobookshelf.enable (mkLibrary "Audiobooks" "books" [ "/mnt/media/audiobooks" ])}
    </ArrayOfVirtualFolder>
  '';
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.jellyfin.preStart = lib.mkAfter ''
      mkdir -p ${srePaths.stateDir}/jellyfin/root/default
      cp -f ${libraryXml} ${srePaths.stateDir}/jellyfin/root/default/libraries.xml
      chown -R jellyfin:media ${srePaths.stateDir}/jellyfin/root
    '';
  };
}
