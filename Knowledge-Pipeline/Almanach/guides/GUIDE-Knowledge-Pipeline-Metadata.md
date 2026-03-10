# [GUIDE]: Knowledge Management Pipeline (Metadata Tagging)
# ID: [NUGGET-SRE-007] | Status: PROPOSED | Stand: 10.03.2026

## 1. Vision
Automatisierte Sichtung und Kategorisierung von großen Mengen an unstrukturierten Dokumenten (Chatlogs, Notizen) durch Wort-Quantisierung und heuristisches Scoring.

## 2. Drei-Stufen-Protokoll
### Stufe 1: Token-Extraktion
- Wortlänge ≥ 4 Zeichen.
- Ausschluss von DE/EN Stoppwörtern.
- Split von CamelCase und kebab-case.

### Stufe 2: Heuristisches Scoring
- **Dateiname:** 3x Gewichtung.
- **Header (##):** 2x Gewichtung.
- **Nomen (Großschreibung):** 1.5x Gewichtung.
- **Fließtext:** 1x Gewichtung.

### Stufe 3: Mapping
Zuordnung zu den 11 Kern-Layern (00-core bis 90-policy) basierend auf der Tag-Cloud.

## 3. Tooling
Geplant ist ein Python-Skript (`goldmine_extractor.py`), das diesen Prozess lokal in der Erzmine (`01-PROCESSING`) umsetzt.

---
> [SOURCE]: Erzmine/02-ARCHIVE/Claude-Dokumentenverwaltung mit automatischer Metadaten-Tagging.md
