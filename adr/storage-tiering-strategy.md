---
title: "ABC Storage Masterplan: The Definitive Tiering & ZFS Tweak"
category: "adr"
tags: [storage, architecture, zfs, nvme, optimization, ashift, mergerfs]
date: 2026-03-08
source: "architectural-legacy-v6.7"
status: "live-validated-v6.7-definitive"
---

# 🏛️ [ADR-INFO]: ABC STORAGE & MOVER SYSTEM (DEFINITIVE EDITION V6.7)

Dieses Dokument vereint deine "Friedhofs-Logik" mit den aktuellsten SRE-Best-Practices für NVMe-Speicher unter NixOS 24.11/25.05.

---

## 🏗️ 1. USER LAYER: DIE LAGERHAUS-LOGIK (KISS)
Das System verwaltet deinen Speicher wie ein intelligentes, kaskadierendes Lagerhaus:
- **Tier A (Hot/NVMe):** Der Hochgeschwindigkeits-Arbeitstisch. Blitzschnell durch ZFS-Optimierung.
- **Tier B (Warm/SSD):** Das Zwischenlager. Hier landen neue Pakete und Überlauf-Daten.
- **Tier C (Cold/HDD):** Der Friedhof. Hier ruhen Medien ohne unnötigen Energieverbrauch.

---

## 🛠️ 2. TECHNICAL LAYER: AVIATION-GRADE SPEZIFIKATION

### A. Tier A (NVMe) — ZFS Härtung
Wir optimieren ZFS für die spezifischen Charakteristika von NVMe-Flash-Speicher:
| Option | Wert | Rationale |
| :--- | :--- | :--- |
| **`ashift`** | `12` | Korrekte Ausrichtung auf 4K-Sektoren (NAND-Alignment). |
| **`compression`** | `zstd` | Maximale Durchsatz-Erhöhung bei geringer CPU-Last. |
| **`xattr`** | `sa` | Metadaten-Speicherung im Inode (Speedup für Nix-Store). |
| **`atime`** | `off` | Verhindert Schreibvorgänge bei jedem Lesezugriff (SSD-Schutz). |
| **`autotrim`** | `on` | Echtzeit-Bereinigung freier Blöcke. |

> [LIVE-ENRICHMENT]: Für den Mountpoint `/nix` setzen wir die `recordsize` auf **1M**. Dies reduziert den Metadaten-Overhead beim Laden großer Nix-Binärpakete massiv.

### B. Die bidirektionale Platzlogik (A <-> B)
Tier A fängt alle Metadaten (Klasse B) als "Gäste" ab.
- **Evakuierung:** Bei >95% Belegung auf A werden B-Daten physisch nach B (EXT4) verschoben.
- **Promotierung:** Bei <50% auf A wandern Metadaten für maximalen Speed zurück.

### C. Tier B/C Pool — MergerFS Design
Nutzung von MergerFS mit `category.create=mfs` (Most Free Space), um die EXT4-Platten gleichmäßig zu füllen, ohne die HDDs für jeden Schreibvorgang zu wecken.

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum EXT4 für den Friedhof?
Medien-Archive auf Tier C brauchen keine ZFS-Komplexität. EXT4 bietet den Vorteil der "Safe-Recovery": Jedes Standard-Linux-Live-System kann diese Daten im Katastrophenfall ohne `zpool import` sofort lesen.

### Warum Hysterese (90% -> 80%)?
Um "Trashing" (ständiges Hin- und Her-Schieben kleiner Dateimengen) zu vermeiden. Der Mover sammelt Arbeit, bis ein substanzieller Batch (10% der Platte) verschoben werden kann.

---

## 🧠 SRE-KONSEQUENZEN
- **Integrität:** Tier A wird durch ZFS-Checksummen gegen Silent Data Corruption geschützt.
- **Reliability:** Tier B & C sind durch ihre Einfachheit (EXT4) gegen Software-Fehler im ZFS-Stack immun.

---

## 📈 VIII. KUMULATIVE VEREDELUNG (BATCH 1)

> [SEARCH-ENRICHMENT]: Für moderne Linux-Kernel (6.12+) und ZFS auf NVMe wird die Anpassung des `zfs_arc_max` empfohlen, um den RAM-Verbrauch des Host-Systems (Fujitsu Q958) stabil zu halten. 
> ```nix
> boot.kernelParams = [ "zfs.zfs_arc_max=4294967296" ]; # Begrenzung auf 4GB RAM
> ```

> [SEARCH-ENRICHMENT]: In MergerFS v2.40+ (NixOS 24.11) verbessert die Option `cache.files=auto-full` die Performance beim gleichzeitigen Streaming mehrerer 4K-Quellen von Tier C erheblich, indem Metadaten intelligenter gepuffert werden.

> [ARCHITECT-NOTE]: Um das Risiko von Datenverlusten beim Mover-Prozess (A -> B) zu minimieren, integrieren wir einen `zfs snapshot` Befehl unmittelbar VOR der Evakuierung. Dies erlaubt ein sofortiges Rollback, falls rsync auf Tier B einen Fehler meldet.
