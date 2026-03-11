# GEMINI.md – Die Master-Verfassung (v14.1)
# Status: INTELLIGENT SOVEREIGN ARCHITECTURE | Stand: März 2026
# Supersedes: v14.0, v13.0, v12.0, v11.0, v10.0, v7.0
# ADR-040:           LAW OF ASSOCIATIVE MINING        – AKTIV
# AKINATOR-PROTOCOL: REQUIREMENTS FIRST               – AKTIV
# ELASTIC-RAM-LAW:   DYNAMIC BUFFERING (10%/20%)      – AKTIV
# TIER-D-USB-LAW:    TRANSIENT AUTOMOUNT & SYNC       – AKTIV

---

## PREAMBLE: BETRIEBLICHES GRUNDGESETZ

Dies ist die einzige Quelle der Wahrheit (Single Source of Truth, SSoT) für alle KI-Agenten
(Gemini CLI, Claude) im "mynixos"-Framework. Jede Abweichung ist ein Systemfehler.

**Authorship:** Mo (Entscheidungsträger) + Claude (Architecture Master) + Gemini CLI (On-Server Execution)
**Evolution:** v14.0 (Intelligenz) → v14.1 (Elastic & Map)
**Archive:** Alle Vorgänger liegen in `/home/Knowledge-Pipeline/oldGeminis/`

---

## [SEKTIONEN 0 BIS XV IDENTISCH ZU v14.0 - GEKÜRZT FÜR SSOT-KOMPAKTHEIT]

---

## XVI. ELASTIC SOVEREIGNTY & STORAGE INTELLIGENCE

Diese Sektion kodifiziert das intelligente Verhalten des Systems gegenüber RAM-Nutzung und externer Hardware.

### A. [GESETZ: ELASTIC RAM]
Das System nutzt den Arbeitsspeicher als dynamischen Schutzschild.
- **Root-on-Tmpfs:** Nutzt `size=10%` des verfügbaren RAMs, mit einem harten Cap bei **2GB**.
- **SSD-Schutz (Dirty Cache):** `vm.dirty_ratio` wird auf **20%** gesetzt. Dies erlaubt massive Schreibpuffer im RAM (z.B. 3.2GB bei 16GB RAM), um NVMe-Schreibzyklen zu bündeln und die Hardware zu schonen.
- **Valkey-Limit:** Der In-Memory Cache wird auf `maxmemory 512MB` limitiert.

### B. [GESETZ: TIER-D USB]
Externe Medien werden als 'Transient' eingestuft.
- **Automount:** Zugriff via `/mnt/transient/<label>`.
- **Idle-Timeout:** Automatischer logischer Unmount nach **300 Sekunden** Inaktivität.
- **Sync-Mandat:** Mount-Option `sync` ist Pflicht für Tier D, um Datenkorruption beim plötzlichen Abziehen ("Oops-Moment") zu verhindern.

### C. [GESETZ: SOVEREIGN MAP]
Jede Tier C/D Platte wird beim Mounten physisch indiziert.
- **Tool:** `nixh-index-usb` (Python/SQLite/Valkey).
- **Logik:** Die Landkarte der Dateien liegt auf Tier A (NVMe). HDDs bleiben im Deep Sleep (Spin-down), solange nur in der Metadaten-Landkarte gesucht wird.

### D. [GESETZ: SPY-MONITORING]
Volle Transparenz über HDD-Wakeups.
- **Standard-Tool:** `fatrace` (File Access Trace).
- **Alias:** `nixh-disk-spy` zeigt live, welcher Prozess (PID) auf welche Datei im Storage-Pool zugreift.

---

*GEMINI.md v14.1 – Generiert: März 2026*
*Reconciliation Log v14.1: Integration von Elastic RAM (10%/20%), USB-Automount (sync) und Smart Indexing.*
