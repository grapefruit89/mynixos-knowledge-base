---
title: ADR-006: Tiered Storage Strategy (ZFS + ext4 Hybrid)
status: [ACCEPTED]
category: architecture/decision
capabilities: [zfs-integrity, ext4-spindown, no-snapraid]
---

# 🏛️ ADR-006: Hybrid-Storage (Revision v2.0)

## Kontext
Maximale Skalierbarkeit und Datenintegrität für kritische Daten (Tier A) bei gleichzeitigem maximalem Spindown für Medien (Tier C).

## Entscheidung
1. **Tier A (NVMe):** ZFS Single-Node. Hier liegt /persist und alle Datenbanken. Wir nutzen ZFS-Snapshots für Instant-Recovery. ✅
2. **Tier B/C (HDDs):** Natives ext4 pro Platte. KEIN SnapRAID (zu viel Overhead/Komplexität).
3. **Pooling:** MergerFS verbindet die ext4 Platten zu einem logischen Pfad (/mnt/storage).

## Begründung
- **Stabilität:** ZFS schützt die System-Integrität auf dem NVMe.
- **Energie:** ext4 erlaubt den saubersten HDD-Spindown ohne Metadaten-Wakeups.
- **KISS:** Verzicht auf SnapRAID reduziert die Maintenance-Last.