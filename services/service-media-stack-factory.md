# Service: Media Stack Factory (Standardized ARR-Stack)

## 1. User Layer (KISS)
Dieses Dokument beschreibt die "Fließband-Produktion" deiner Medien-Dienste (wie Sonarr oder Radarr). Anstatt jeden Dienst mühsam einzeln einzustellen, nutzen wir eine Vorlage (Factory). Diese sorgt dafür, dass alle Dienste automatisch sicher eingesperrt sind, die richtige Geschwindigkeit (SSD für Cover, HDD für Filme) nutzen und bei Bedarf sicher über eine VPN-Verbindung ins Internet gehen.

## 2. Technical Layer (Aviation-Grade)

### Architektur der Factory
Die `mkMediaService` Funktion abstrahiert die Komplexität des Media-Stacks:
1.  **VPN-Enforcement:** Dienste mit `useVpn = true` werden zwingend in den `media-vault` Network Namespace verschoben.
2.  **Storage-Tiering:** 
    *   **Tier A (SSD):** `/var/lib/${name}` (Datenbanken) und `/mnt/fast-pool/metadata` (Cover-Bilder).
    *   **Tier C (HDD):** `/mnt/media` (Eigentliche Film-Dateien).
3.  **SRE-Quotas:** Automatische RAM-Limitierung basierend auf globalen SSoT-Werten (`maxMediaRamMB`).

### Hardening Baseline
Alle ARR-Dienste erhalten ein standardisiertes Sandboxing:
*   `CapabilityBoundingSet = ""`: Keine privilegierten Kernel-Zugriffe.
*   `ProcSubset = "pid"`: Der Dienst sieht nur seine eigenen Prozesse.
*   `ProtectSystem = "full"`: Das Betriebssystem ist für den Dienst schreibgeschützt.

### Integration (Nix-Snippet)
```nix
# Beispiel: Instanziierung in sonarr.nix
mkMediaService {
  name = "sonarr";
  port = 8989;
  useVpn = true;
  stateOption = "dataDir";
}
```

## 3. Reasoning Layer (History)

### [ADR-030] Factory Pattern vs. Individual Modules
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Die manuelle Pflege von 5+ ARR-Diensten führt zu Inkonsistenzen bei Sicherheitseinstellungen und Pfaden.
*   **Entscheidung:** Nutzung einer zentralen Factory-Funktion (`_lib.nix`).
*   **Vorteile:** 100% konsistente Sicherheits-Level. Ein Update der Hardening-Regeln in der Factory verbessert sofort alle Medien-Dienste.
*   **Spezialfall Jellyfin:** Jellyfin wird zwar über die Factory vorbereitet, erhält aber manuelle Overrides für den GPU-Zugriff (QuickSync), da dies ein weniger restriktives Sandboxing erfordert.

---
**Sources:**
*   `40-media/service-media-_lib.nix`
*   `40-media/service-media-_servarr-factory.nix`
*   `00-core/configs.nix`
