# [ADR-038]: Exposed Media Service Hardening (Platin Standard)
# ID: [ADR-038] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Dienste wie Jellyfin sind große Angriffsflächen. Wir sperren sie in einen Container (Käfig), limitieren ihren Dateizugriff (Aquarium) und lassen Caddy den Türsteher spielen (Zimmer).

## 2. Technical Layer (Spezifikation)
- **Container:** `containers.media-vault` (systemd-nspawn).
- **Isolation:** `privateNetwork = true`. Der Container sieht das Host-LAN nicht direkt.
- **Hardware-Passthrough:** `/dev/dri` (Intel QuickSync) wird in den Container gemountet, damit 4K-Streaming weiterhin flüssig läuft.
- **Storage-Mounts:** Nur `/mnt/media` wird als Read-Only (Aquarium) hineingereicht. Nur der Transcoding-Ordner ist beschreibbar.

## 3. Reasoning Layer
- **Risiko-Minimierung:** Falls Jellyfin gehackt wird, bleibt der Angreifer im Container gefangen.
- **Effizienz:** Trotz maximaler Sicherheit nutzen wir die volle Power der i3-CPU (QuickSync) durch gezielten Device-Passthrough.

---
> [SOURCE]: Architektur-Diskussion "Käfig im Aquarium" (10.03.2026)
