---
title: 🏗️ ABC-Storage-Tiering (The MergerFS Standard)
category: architecture/storage
status: [ACTIVE-SSoT]
capabilities: [mergerfs-pooling, zfs-integrity, snapraid-parity, storage-efficiency]
sources: [https://perfectmediaserver.com/02-tech-stack/nixos/]
---

# 🏗️ ABC-Storage-Tiering: Die intelligente Daten-Hierarchie

Wir trennen Performance von Kapazität. In mynixos nutzen wir drei Ebenen (Tiering), um Kosten und Geschwindigkeit zu optimieren.

## 🔴 Tier A: Performance (ZFS Native)
- **Medium:** NVMe SSDs (Mirror).
- **Inhalt:** OS, Flakes, PostgreSQL, Datenbanken.
- **Vorteil:** Maximale IOPS, atomare Snapshots via ZFS.

## 🟡 Tier B: Productivity (SSD)
- **Medium:** SATA SSDs.
- **Inhalt:** n8n Workflows, App-Configs, Caches.

## 🔵 Tier C: Capacity (MergerFS + SnapRAID)
- **Medium:** Mismatch-HDDs (beliebige Größen).
- **Inhalt:** Medien (Filme, Serien, Hörbücher).
- **Vorteil (The MergerFS Logic):** 
    - Einfache Erweiterbarkeit (Platte rein, fstab-Zeile anpassen, fertig).
    - Jede Platte bleibt einzeln lesbar (Kein Datenverlust des gesamten Pools bei Ausfall).
    - SnapRAID sorgt für die Parität (Schutz vor Festplattentod ohne RAID-Komplexität).

## ⚙️ Implementierung in NixOS
Wir nutzen das \`virtualisation.mergerfs\` Modul (oder direkt \`fileSystems\`), um die Platten zu poolen:
\`\`\`nix
fileSystems."/mnt/storage" = {
  device = "/mnt/disk*";
  fsType = "fuse.mergerfs";
  options = [ "defaults", "allow_other", "moveonenospc=true", "category.create=mfs" ];
};
\`\`\`