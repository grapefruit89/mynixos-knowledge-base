# GEMINI.md – Die Master-Verfassung (v14.2)
# Status: INTELLIGENT SOVEREIGN ARCHITECTURE | Stand: März 2026
# Supersedes: v14.1, v14.0, v13.0, v12.0, v11.0, v10.0, v7.0
# ADR-040:           LAW OF ASSOCIATIVE MINING        – AKTIV
# AKINATOR-PROTOCOL: REQUIREMENTS FIRST               – AKTIV
# CAPPED-RAM-LAW:    FIXED BUFFERING (1G/512MB)       – AKTIV
# TIER-D-USB-LAW:    TRANSIENT AUTOMOUNT & SYNC       – AKTIV

---

## PREAMBLE: BETRIEBLICHES GRUNDGESETZ

Dies ist die einzige Quelle der Wahrheit (Single Source of Truth, SSoT) für alle KI-Agenten
(Gemini CLI, Claude) im "mynixos"-Framework. Jede Abweichung ist ein Systemfehler.

---

## XVI. CAPPED SOVEREIGNTY & STORAGE INTELLIGENCE

### A. [GESETZ: CAPPED RAM]
Das System nutzt den Arbeitsspeicher effizient und berechenbar.
- **Root-on-Tmpfs:** Nutzt ein festes Limit von `size=1G`. Dies reicht für die Systemstruktur aus und schont den RAM.
- **SSD-Schutz (Dirty Cache):** Der Schreibpuffer ist auf exakt **512MB** (`vm.dirty_bytes`) begrenzt. Der Hintergrund-Flush startet ab **256MB** (`vm.dirty_background_bytes`). Dies schützt die SSD vor Abnutzung durch kleine Schreibzugriffe, ohne den RAM zu überfluten.

### B. [GESETZ: TIER-D USB]
Externe Medien sind 'Transient'.
- **Automount:** Zugriff via `/mnt/transient/<label>`.
- **Idle-Timeout:** Automatischer logischer Unmount nach **300 Sekunden** Inaktivität.
- **Sync-Mandat:** Mount-Option `sync` ist Pflicht für Tier D (Datensicherheit vor Geschwindigkeit).

### C. [GESETZ: SMART INDEXING]
Jede Tier D Platte wird beim Mounten via `nixh-index-usb` indiziert.
- **Landkarte:** Pfade werden in SQLite (`/persist/metadata/usb.db`) und Valkey gespeichert.
- **Zweck:** Ermöglicht Dateisuche ohne HDD-Wakeup.

---

*GEMINI.md v14.2 – Generiert: März 2026*
*Reconciliation Log v14.2: RAM-Capping (1G/512MB) und USB-Indexing Standard.*
