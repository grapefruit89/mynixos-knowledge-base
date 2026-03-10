# [ADR-012]: ABC Storage Tiering & MergerFS
# ID: [NUGGET-STOR-001] | Status: ACCEPTED | Stand: 10.03.2026

## 1. Context (User Layer)
Ein Media-Server (Jellyfin, *arr) braucht viel Platz (HDD) und gleichzeitig hohe Geschwindigkeit für Metadaten/Cover (SSD), sonst lädt die UI zu langsam.

## 2. Decision (Technical Layer)
Wir nutzen ein "ABC-Tiering" Modell, erzwungen durch systemd-tmpfiles und mergerfs.

- **Tier A (Fast-Pool):** NVMe/SSD für `/mnt/fast-pool/metadata` und `/mnt/fast-pool/cache`.
- **Tier B (Storage-Pool):** HDDs für `/mnt/storage/media`.
- **Tier C (Archiv):** Offsite/Cold Storage.

### 2.1 Umsetzung in der Werkstatt (Referenz aus Backup)
```nix
# Globale Media-Gruppe für reibungslosen Zugriff
users.groups.media = { gid = 169; members = [ "jellyfin" "sabnzbd" "sonarr" "radarr" ]; };

# Kanonisches Layout via tmpfiles
systemd.tmpfiles.rules = [
  "d /mnt/media/movies 0775 radarr media -"
  "d /mnt/fast-pool/metadata 0775 root media -"
];

# Bind-Mounts für rasante UI (Service-Level)
systemd.services.sonarr.serviceConfig.BindPaths = [
  "/mnt/fast-pool/metadata/sonarr:/var/lib/sonarr/MediaCover"
];
```

## 3. Reasoning (Reasoning Layer)
- Durch gezielte `BindPaths` (Bind-Mounts) auf Dienst-Ebene wird SSD-Speed für Bilder/Datenbanken erreicht, während die echten Videodateien auf den günstigen HDDs liegen.
- `systemd.tmpfiles.rules` erzwingt die Ordnerstruktur beim Boot, sodass fehlende Ordner sofort korrigiert werden.
