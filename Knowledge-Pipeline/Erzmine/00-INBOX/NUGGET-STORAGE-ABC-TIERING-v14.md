# [NUGGET-STORAGE-ABC-TIERING] Sovereign Multi-Tier Storage (v14.0)
# Status: Stage 1 (Raw-Research) | Version: 1.0
# [META] ID: NIXH-KNOW-STORAGE-001 | REQ_REFS: [ADR-012, ADR-040]

## 1. USER LAYER (KISS)
Das System nutzt drei verschiedene "Geschwindigkeitsstufen" (Tiers), um maximale Performance für Datenbanken und maximale Effizienz für Filme zu erreichen.
- **Tier A (Hot):** Schnelle interne NVMe für das Betriebssystem und Datenbanken.
- **Tier B (Warm):** Interne SSD für Dokumente und Bilder.
- **Tier C (Cold):** Große HDDs für Filme und Musik.
- **Sicherheits-Regel:** USB-Sticks werden niemals automatisch als festes System-Laufwerk genutzt.

## 2. TECHNICAL LAYER (SPECIFICATION)

### Tier A: Hot Storage (ZFS)
- **Filesystem:** ZFS (Native Encryption & Compression)
- **Recordsize:** 16k (Optimiert für PostgreSQL 8k Pages)
- **Benefits:** Reduziert Write-Amplification von 16:1 auf 2:1. Massiv verlängerte SSD-Lebensdauer und hohe IOPS.
- **Mount:** `/`, `/var/lib/postgresql`.

### Tier B: Warm Storage (Btrfs)
- **Filesystem:** Btrfs (Zstd Compression)
- **Benefits:** Gute Balance zwischen Platzersparnis und Performance für Metadaten.
- **Mount:** `/var/lib/paperless`, `/var/lib/nextcloud`.

### Tier C: Cold Storage (XFS)
- **Filesystem:** XFS (Reflinks enabled)
- **Blocksize:** 4k (Zwingend durch Kernel Page Size Limit auf x86_64).
- **Optimization:** Nutzung von `inode64` und `allocsize=64m` Mount-Optionen zur Reduzierung der Fragmentierung bei >10GB Files.
- **Mount:** `/data/media`.

### Bus-Guard (PCI vs. USB)
- **Detektion:** `/sys/class/block/<dev>/removable == 1` oder Vorhandensein von `usb` im `/dev/disk/by-path/`.
- **Enforcement:** Disko-Konfigurationen nutzen ausschließlich `by-label`. Eine Nix-Assertion verhindert das Booten, wenn `DISK_SYSTEM` an einem USB-Bus hängt.

## 3. REASONING LAYER (ADR)
- **Warum ZFS 16k?** Standard 128k führt bei DB-Workloads zu massivem "Read-Modify-Write" Overhead. 16k ist der effizienteste Kompromiss für NVMe.
- **Warum kein XFS 64k?** Technisches Hard-Limit: Linux auf x86_64 unterstützt keine Blocksizes > Page Size (4k).
- **Warum Bus-Guard?** Verhindert "Silent Failures" und versehentliche Datenverluste, wenn Boot-Labels auf externen Medien gefunden werden.
