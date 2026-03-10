---
title: 🚀 Future Storage Scaling (Tier C Evolution)
category: architecture/storage
status: [PROPOSED]
capabilities: [bitrot-protection, multi-tb-scaling, cow-filesystems, bcachefs-audit]
sources: [Linux Kernel Mailing List, Linus Torvalds Rants, Bcachefs Docs]
---

# 🚀 Skalierung: Der Weg über 5TB

Wenn dein Datenbestand auf Tier C (Medien) die 5TB Grenze überschreitet, reicht ext4 + Scrubbing nicht mehr aus. Wir planen den Umstieg auf ein modernes CoW (Copy-on-Write) Dateisystem.

## 🏛️ 1. Die Kandidaten für Tier C (Medien-Pool)

### A. Btrfs (Der vernünftige Standard)
- **Vorteil:** Nativ im Kernel, beherrscht Checksummen gegen Bitrot, unterstützt Kompression (spart Platz) und erlaubt HDD-Spindown.
- **SRE-Status:** Aviation-Grade Ready. ✅

### B. Bcachefs (Das "Rage" Dateisystem)
- **Hintergrund:** Von Linus Torvalds massiv kritisiert wegen des unsauberen Entwicklungsprozesses ("beyond ridiculous").
- **Vorteil:** Kombiniert die Performance von XFS mit der Integrität von ZFS und integriertem SSD-Caching.
- **SRE-Status:** **Bleeding Edge.** Nur für SREs, die bereit sind, Kernel-Bugs zu jagen. Momentan NICHT für Produktivdaten empfohlen. ❌

## ⚙️ 2. Zukunfts-Architektur (v9.0 Vision)
- **Tier A (NVMe):** ZFS (Single Node).
- **Tier C (HDDs):** Btrfs RAID-0 oder Einzel-Disks mit globalen Checksummen.
- **Migration:** Daten werden via \`rclone\` oder \`rsync --inplace\` (Kapitel 50) atomar umgezogen.

## 🛡️ SRE-Fazit
Wir priorisieren **Integrität vor Watt**, sobald die Datenmenge kritisch wird. Btrfs ist der sicherste nächste Schritt. Bcachefs bleibt im Monitoring-Status.