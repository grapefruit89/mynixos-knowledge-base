---
title: "ABC Storage Mover: The Precision Engine"
category: "services"
tags: [storage, mover, systemd, logic, hdd-protection, hysteresis]
date: 2026-03-08
source: "architectural-legacy-v5.3"
status: "verified-substance-v5.3-definitive"
---

# 🏗️ SERVICE: PRECISION STORAGE MOVER (THE ENGINE)

Dieser Dienst automatisiert das Daten-Tiering und schützt die mechanische Hardware.

---

## 🛠️ TECHNISCHE SPEZIFIKATION

### 1. Das "Shopping-List" Skript (03:00 Uhr)
Ein systemd-Service scannt Tier B (SSD), ohne die HDDs aufzuwecken.
```bash
find /mnt/warm-ssd/downloads -type f -atime +30 > /run/mover/shopping-list.txt
```

### 2. Der Hysterese-Controller (90% -> 80%)
Der Mover agiert nicht linear, sondern in Schüben, um Fragmentation und unnötige Platten-Aktivität zu vermeiden.
- **Panic-Mode:** Bei >95% Belegung wird der Move erzwungen.
- **Normal-Mode:** Bei >90% Belegung wird auf die Aktivierung der HDDs gewartet.

### 3. Opportunistisches Verschieben
Der Dienst überwacht den Status der HDDs via `hdparm`.
```bash
if hdparm -C /dev/disk/by-id/your-hdd | grep -q "active/idle"; then
    if [ $(df --output=pcent /mnt/warm-ssd | tail -1 | tr -dc "0-9") -gt 90 ]; then
        # Führe rsync Batch aus der shopping-list aus
    fi
fi
```

---

## 🛡️ SICHERHEITS-FEATURES
- **Atomic-Move:** Nutzt `rsync -a --remove-source-files`, um Datenverlust bei Stromausfall zu verhindern.
- **Incomplete-Protection:** Verzeichnisse mit dem Muster `*/incomplete/*` werden strikt ignoriert.
- **Struktur-Hygiene:** Leere Verzeichnisse auf der SSD werden nach dem Transfer automatisch gelöscht (`find -empty -delete`).
