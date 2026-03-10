# 🏗️ [ADR]: Storage Broker & ABC-Tiering (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir führen ein "Lagersystem" für deine Daten ein. Schnelle Daten (NVMe) kommen in Schublade A, normale Daten (SSD) in B und Massendaten (HDD) in C.
- **Problem:** Momentan schreiben viele Dienste ihre Daten wild durcheinander, was zu Unordnung und Performance-Problemen führt.
- **Lösung:** Ein zentraler "Lagerverwalter" (Storage Broker). Jede App (wie Sonarr) sagt nur noch: "Ich brauche Platz für meine Filme", und der Broker gibt ihr automatisch den richtigen Pfad im richtigen Tier.
- **Vorteil:** Keine Pfad-Kollisionen mehr und automatische Optimierung für Geschwindigkeit und Speicherplatz.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation des Storage-Brokers (`00-core/hal-storage.nix`).

### 📂 2.1 Tier-Definitionen
- **Tier 0 (RAM):** `/run/nixhome-cache` (tmpfs) — Flüchtige Caches, flüssiges Arbeiten.
- **Tier A (NVMe):** `tA-nvme` (ext4) — Kritischer App-State, Datenbanken.
- **Tier B (SSD):** `tB-ssd` (ext4) — Metadaten, Transcoding-Cache.
- **Tier C (HDD):** `tC-bulk` (mergerfs) — Bulk-Daten (Medien, Backups).

### ⚙️ 2.2 Funktionsweise (Broker Logic)
- **Path Registry:** Zentrale Liste aller erlaubten Pfade (`nixhId`, `tier`, `subPath`).
- **mkStoragePath:** Einzige API für Service-Module. Gibt den absoluten Pfad zurück.
- **Kollisions-Detektion:** Build-Abbruch bei doppelten `subPaths` im gleichen Tier.
- **Ownership:** Automatische Vergabe von Berechtigungen (User, Group, Mode) via `systemd.tmpfiles`.

```nix
# Jellyfin nutzt den Broker
stateDir = config.my.hal.storage.mkPath "NIXH-40-MED-007" "tA-nvme";
```

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Zentralisierung:** Verhindert "wilden" State-Wuchs im System. Jedes Verzeichnis muss im HAL angemeldet werden.
- **Isomorphie-Garantie:** Da Pfade zur Evaluierungszeit generiert werden, ist die Konfiguration immer konsistent mit dem Dateisystem.
- **Persistenz-Logik:** Tier A und B sind explizit für Persistence vorgesehen, während Tier 0 und Tier B (Caches) oft flüchtig behandelt werden können.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-03 Prompt-Übernahme anfragen.md` (Conversational SRE Review 3.3.2026).
