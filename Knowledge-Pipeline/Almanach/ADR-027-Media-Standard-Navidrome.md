# [ADR-027]: High-Performance Audio Streaming (Navidrome)
# ID: [ADR-027] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir nutzen Navidrome als unseren Standard für Musik-Streaming. Es ist extrem schnell, verbraucht kaum Ressourcen und funktioniert perfekt mit mobilen Apps (Subsonic-kompatibel).

## 2. Technical Layer (Spezifikation)
- **Target:** MyNixOS Layer 40 (Media).
- **Tool:** `pkgs.navidrome` / `services.navidrome.enable`.
- **Sprache:** Go (Binary-Effizienz-Mandat).
- **Features:** Automatisches Scannen der Bibliothek, extrem niedriger RAM-Footprint.

## 3. Reasoning Layer (ADR)
- **Wahl:** Navidrome ist die Aviation-Grade Wahl gegenüber Plex oder Jellyfin (für Musik), da es spezialisierter und performanter ist.
- **Persistence:** Nutzt SQLite für die Metadaten.
- **Integration:** Läuft hinter Caddy mit TLS.

---
> [SOURCE]: https://github.com/navidrome/navidrome
