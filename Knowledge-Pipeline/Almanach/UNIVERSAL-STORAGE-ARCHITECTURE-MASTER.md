# 📗 UNIVERSAL-STORAGE-ARCHITECTURE-MASTER (The ISO-Standard)
# ID: [MANUAL-STORAGE-001] | Stand: 10.03.2026 | Status: DEFINITIVE-SSoT

Dieses Dokument ist das ultimative Engineering-Handbuch für die Storage-Architektur der mynixos Distribution. Es entkoppelt die logische Datenstruktur von der physischen Hardware durch den Einsatz von funktionalen Rollen und Disk-Labels.

---

## 🏛️ A. PHILOSOPHY: SOUVERÄNITÄT DURCH ABSTRAKTION

### 1. Autonomie vs. RAID
Wir lehnen RAID (Redundant Array of Independent Disks) und SnapRAID für den produktiven Media-Stack ab. 
- **Das No-RAID Mandat (ADR-040):** 100% Nutzkapazität des Speichers. Jede Festplatte ist ein autonomer Bürger.
- **Warum?** RAID-Systeme (besonders ZFS-Pools) verhindern den individuellen HDD-Spindown. Wir priorisieren Energieeffizienz und Hardware-Schonung vor lokaler Echtzeit-Redundanz.
- **Sicherheit:** Redundanz erfolgt durch geografische Distanz (Backups nach S3/Cloud) gemäß dem **Distance Parity Mandate (ADR-015)**.

### 2. Rollenbasierte Abstraktion (ISO-Standard)
Anstatt Hardware-Slots (wie "WLAN-Slot" oder "SATA-0") zu definieren, operieren wir mit funktionalen Rollen. Dies ermöglicht die Portabilität der Konfiguration auf jedes beliebige System.
- **DISK_SYSTEM:** Der Anker des Betriebssystems.
- **DISK_CACHE:** Die Hochgeschwindigkeits-Pufferzone.
- **DISK_STORAGE_n:** Die unendliche Weite des Archivs.

---

## 💾 B. TIER SPECIFICATIONS (TECHNICAL FLAGS)

### 🔴 Tier A: DISK_SYSTEM (The Foundation)
- **Label-Pflicht:** `DISK_SYSTEM`
- **Dateisystem:** **ZFS (Single Node)**
- **Zweck:** OS, /persist, PostgreSQL, Identity-State, Secrets.
- **Mount-Optionen:**
  ```nix
  {
    atime = false;
    compression = "zstd";
    xattr = "sa";
    acltype = "posixacl";
  }
  ```
- **Reasoning:** ZFS bietet Bitrot-Schutz für kritische Daten und erlaubt atomare Snapshots des Systemzustands vor riskanten Updates.

### 🟡 Tier B: DISK_CACHE (The Engine)
- **Label-Pflicht:** `DISK_CACHE`
- **Dateisystem:** **ext4** oder **xfs**
- **Zweck:** Transcoding-Cache (Jellyfin), Download-Puffer (SABnzbd), Ingest-Zone.
- **Mount-Optionen:** `noatime,nodiratime,discard`.
- **Reasoning:** Minimale Latenz für flüchtige Daten. ext4 wird bevorzugt, da es keine nennenswerte Hintergrund-IO erzeugt, die den Datenträger unnötig belastet.

### 🔵 Tier C: DISK_STORAGE_n (The Archive)
- **Label-Pflicht:** `DISK_STORAGE_01`, `DISK_STORAGE_02`, ...
- **Dateisystem:** **ext4** (Einzelplatten)
- **Zweck:** Bulk Media (Filme, Serien, Musik), Restic-Repository Backups.
- **Mount-Optionen:** `defaults,noatime,lazytime`.
- **Reasoning:** ext4 erlaubt den saubersten HDD-Spindown über `hdparm` oder `hd-idle`, da Metadaten-Updates minimiert werden können.

---

## 🔄 C. THE ATOMIC PROTOCOL (MERGERFS & ATOMIC MOVES)

Um **Atomic Moves** (zero-copy Hardlinks/Renames) zwischen der Download-Zone und der Medienbibliothek zu garantieren, muss die physikalische Einheit gewahrt bleiben.

### 1. Das .staging-Prinzip
Ein "Atomic Move" kann physisch nur innerhalb der gleichen Partition stattfinden. Daher nutzen wir MergerFS nicht als "schwarzes Loch", sondern steuern die Platzierung präzise.

**Ordnerstruktur pro Platte:**
```
DISK_STORAGE_01/
├── .staging/      <-- Hier landen fertig gestellte Downloads
└── movies/        <-- Zielordner für Radarr
```

### 2. MergerFS Konfiguration (Mandat)
Das Pooling erfolgt über alle Platten, die dem Muster `DISK_STORAGE_*` entsprechen.

**Technische Flags:**
- `fsType = "fuse.mergerfs";`
- **Policy:** `category.create=epmfs` (Existing Path Most Free Space).
  - *Logik:* Wenn Radarr eine Datei in `/mnt/media/movies` anlegt, erzwingt `epmfs`, dass die Datei auf der Platte erstellt wird, auf der der Ordner `movies` bereits existiert. Da dort auch der `.staging` Ordner liegt, kann das Verschieben atomar erfolgen.
- **Optimierung:**
  - `func.getattr=newest`: Verbessert die Metadaten-Performance.
  - `ignore_pp=true`: Ignoriert Pfad-Berechtigungen bei der Erstellung (verhindert Permission-Denial bei On-the-fly Erstellung).
  - `cache.readdir=true`: Beschleunigt das Browsen in großen Verzeichnissen.

---

## 🔋 D. ENERGY & HEALTH (SRE OPERATIONS)

### 1. Spindown-Logik
Jeder autonome Datenträger in Tier C wird individuell verwaltet.
- **Tool:** `hd-idle` (bevorzugt) oder `hdparm`.
- **Parameter:** `hdparm -S 120 /dev/disk/by-label/DISK_STORAGE_01` (10 Minuten Idle).
- **Vorteil:** Im Leerlauf verbraucht das System nur die Energie von Tier A (NVMe). Die mechanischen Platten ruhen.

### 2. Smart-Auditing
- **Tool:** `smartmontools` mit `smartd`.
- **Regel:** Überwachung aller Platten via `by-id` Verknüpfung im `smartd` Config-File, um physikalische Sektorenfehler sofort via **ntfy** (ADR-025) zu melden.

---

## 🗺️ E. FORENSIC SOURCE LOG (AUDIT TRAIL)

| Dokument | Extrahierter Gold-Nugget | Status |
| :--- | :--- | :--- |
| `Storage-Security-Meta.md` | Universal Labels `DISK_SYSTEM/CACHE/STORAGE`. | ✅ Integriert |
| `GUIDE-ABC-Storage-Tiering.md` | MergerFS Mount-Snippet & Hybrid-Idee. | ✅ Integriert |
| `Strategy-Impermanence-Tiered-Storage.md` | Definition der Tier-Prioritäten (A=Speed, C=Archive). | ✅ Integriert |
| `ADR-006-Storage-Cluster-Strategy.md` | ZFS/ext4 Hybrid Begründung. | ✅ Integriert |
| `ADR-009-ABC-Tiering vs MergerFS` | Spindown-Vorteile durch Naming-Isolation. | ✅ Integriert |
| `ADR-040-No-RAID-Mandat` | Ablehnung von Parität/Materialverschwendung. | ✅ Integriert |
| `hardware-spec-q958.md` | Physische Referenz für Tier B (WLAN-Slot). | ✅ Integriert |

---
> [!IMPORTANT]
> Dieses Master-Dokument ist die einzige Quelle der Wahrheit für alle zukünftigen disko- und storage-nix Implementierungen. Alle darin genannten Flags sind als Aviation-Grade Mandate zu betrachten.
