---
id: ADR-003
title: Storage Tier Ring (Tierring) Architecture
status: accepted
date: 2026-03-10
tags: [storage, mergerfs, ssd, hdd, performance]
---

# ADR-003: Storage Tier Ring (Tierring) Architecture

## 1. USER LAYER (KISS)
Der "Storage Tier Ring" (oder Tierring) ist ein intelligentes Speichersystem, das automatisch entscheidet, wo Daten liegen sollen. Schnelle SSDs werden für aktive Schreibvorgänge und häufig genutzte Daten (z.B. Datenbanken, aktive Downloads) genutzt, während kostengünstige, große HDDs für die Langzeitarchivierung (z.B. fertige Filme, Backups) dienen. Durch **mergerfs** werden beide zu einem einzigen großen virtuellen Ordner zusammengefasst.

## 2. TECHNICAL LAYER (Specification)

### Implementierungs-Details (NixOS Module)
Die Umsetzung erfolgt über `systemd.mounts` mit dem Filesystem-Typ `fuse.mergerfs`.

#### Konfigurations-Snippet (Auszug aus `00-core/storage.nix`):
```nix
{
  systemd.mounts = [
    {
      description = "Fast-Pool";
      where = config.my.configs.paths.storagePool;
      what = "/data/storage/b-on-a:/mnt/storage/ssd:/mnt/storage/hdd";
      type = "fuse.mergerfs";
      options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=20G,fsname=fast-pool";
      wantedBy = [ "multi-user.target" ];
    }
  ];
}
```

#### Schlüssel-Parameter:
- **`category.create=ff` (First Found):** MergerFS schreibt Daten prioritär auf das erste Laufwerk in der Liste (`/data/storage/b-on-a` oder SSD), solange dort Platz ist.
- **`minfreespace=20G`:** Sobald die SSD weniger als 20GB frei hat, werden neue Daten automatisch auf die HDD umgeleitet.
- **`cache.readdir=true`:** Optimiert die Performance beim Auflisten großer Medienverzeichnisse.

### Path Enforcement (SRE Standards)
Ein dedizierter Systemd-Dienst (`nixhome-path-enforcement`) sorgt dafür, dass die Verzeichnisstruktur (`downloads`, `mediaLibrary`) und die Berechtigungen (`root:media`) nach jedem Boot korrekt gesetzt sind.

## 3. REASONING LAYER (ADR)

### Warum mergerfs statt RAID oder ZFS?
- **Flexibilität:** Laufwerke unterschiedlicher Größe können jederzeit hinzugefügt werden.
- **Daten-Sicherheit:** Wenn eine Platte ausfällt, sind nur die Daten dieser Platte weg (kein Totalverlust wie bei RAID 0).
- **Energie-Effizienz:** HDDs können in den Standby gehen, während die SSD den aktiven Workload (Fast-Pool) übernimmt.

### Warum "Tierring"?
Standard-Setups nutzen oft nur eine Partition. Der Tiering-Ansatz (SSD -> HDD) schont die Schreibzyklen der SSD und sorgt gleichzeitig für maximale Performance bei I/O-lastigen Aufgaben (Arr-Stack Downloads/Unpacking).

### Alternativen (Verworfen):
- **Bcachefs:** Zu experimentell (Stand 2026).
- **ZFS Special VDEV:** Erfordert identische Laufwerke und ist weniger flexibel bei Erweiterungen im Homelab.

---
> [ARCHITECT-NOTE]: Extrahiert aus mynixos/00-core/storage.nix (v2026.03.02)
