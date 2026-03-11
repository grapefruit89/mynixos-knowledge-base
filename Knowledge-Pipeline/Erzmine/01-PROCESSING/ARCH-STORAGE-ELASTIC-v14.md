# [ARCH-STORAGE-ELASTIC] Technical Reasoning for Dynamic Buffering (v14.1)
# Status: Stage 2 (Nugget) | Version: 1.0
# [META] ID: NIXH-KNOW-ARCH-001 | REQ_REFS: [ADR-012, ADR-033, v14.1]

## 1. USER LAYER (KISS)
Wir haben ein System gebaut, das sich dem verfügbaren Arbeitsspeicher anpasst. Je mehr RAM der Server hat, desto besser schützt er die NVMe-SSD, indem er Downloads und Log-Schreibvorgänge länger im RAM puffert. Externe Platten werden wie bei Unraid "unsichtbar" verwaltet und erst bei echtem Bedarf geweckt.

## 2. TECHNICAL LAYER (SPECIFICATION)

### A. Elastic RAM Calculation
- **Dirty Ratio (20%):** Bei 16GB RAM ergibt dies einen Schreibpuffer von ~3.2GB. Dies ermöglicht es, eine 100Mbit Leitung für ca. 250 Sekunden voll auszulasten, ohne dass ein einziger physischer Schreibvorgang auf der SSD stattfindet.
- **Dirty Background (10%):** Sobald 1.6GB belegt sind, beginnt der Kernel im Hintergrund mit dem Wegschreiben, ohne den Prozess zu blockieren.
- **Root Tmpfs (10%):** Ein dynamisches Limit, das bei 16GB RAM ca. 1.6GB für das flüchtige System bereitstellt (Symlinks, Configs, ephemere Logs).

### B. Storage Tuning (ZFS & XFS)
- **ZFS (Tier A):** Nutzt 16k Records für PostgreSQL (8k Pages). Dies verhindert den "Read-Modify-Write" Overhead von Standard 128k Records.
- **XFS (Tier C):** Nutzt 4k Blocks (Hard-Limit auf x86_64) kombiniert mit `allocsize=64m`. Dies bündelt die physische Allokation auf der HDD und minimiert die Fragmentierung bei großen Videodateien.

### C. USB Transient Logic
- **Options:** `sync,x-systemd.idle-timeout=300`.
- **Logic:** `sync` deaktiviert den Schreibcache auf dem externen Medium. Jeder beendete Schreibvorgang ist physisch abgeschlossen. Der Idle-Timeout sorgt dafür, dass das Dateisystem nach 5 Min Inaktivität sauber geschlossen wird.

## 3. REASONING LAYER (ADR)
- **Warum 20%?** Ein höherer Wert würde bei einem Stromausfall zu zu großem Datenverlust im Puffer führen. 20% (~3GB) ist der ideale Kompromiss zwischen SSD-Schonung und Risiko-Minimierung.
- **Warum sync für USB?** In Homelab-Szenarien werden USB-Medien oft ohne "Auswerfen" abgezogen. Sicherheit (Datenintegrität) hat hier Vorrang vor Geschwindigkeit.
- **Warum Metadata-Map?** Um die Latenz beim Browsen großer HDD-Pools zu eliminieren. Das System fühlt sich an wie eine All-Flash-Umgebung.
