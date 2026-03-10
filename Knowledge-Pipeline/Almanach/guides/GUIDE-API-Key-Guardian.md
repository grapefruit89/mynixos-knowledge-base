# [GUIDE]: Der API-Key Guardian (Pre-Flight Check)
# ID: [NUGGET-SRE-014] | Status: ACTIVE | Stand: 10.03.2026

## 1. Das "Wächter vor den Toren" Prinzip
Um Fehlkonfigurationen (Lapsus) zu vermeiden, darf kein Media-Service starten, ohne dass ein automatisierter Techniker (unser Validierungs-Skript) die API-Verbindungen geprüft hat.

## 2. Der API-Fluss (Tickle Down)
| Dienst | Rolle | Quelle der Wahrheit (Key) |
| :--- | :--- | :--- |
| **Prowlarr** | Indexer-Zentrale | Generiert den Master-Key |
| **Sonarr / Radarr** | Such-Bots | Beziehen Key von Prowlarr |
| **Jellyfin** | Konsum | Bezieht Key von Sonarr/Radarr |

## 3. Die technische Umsetzung (The Skalpell)
Wir nutzen `xmlstarlet`, um XML-Konfigurationen präzise zu bearbeiten, ohne die Dateistruktur zu gefährden.

### Der Validierungs-Algorithmus:
1. **Fetch:** Lese Master-Key aus `/run/secrets/prowlarr_api_key`.
2. **Audit:** Prüfe `config.xml` des Ziel-Dienstes via `xmlstarlet sel`.
3. **Correction:** Bei Abweichung -> `xmlstarlet ed` (Auto-Fix).
4. **Validation:** Bei technischem Defekt -> Systemd-Abbruch + ntfy Alarm.

---
> [SOURCE]: Benutzer-Konzept "Wächter vor den Toren" (10.03.2026)
