---
title: 🏗️ ABC-Storage-Tiering (The Hybrid ZFS + MergerFS Standard)
category: architecture/storage
status: [ACTIVE-SSoT]
capabilities: [zfs-integrity, mergerfs-flexibility, hybrid-pooling, snapraid-parity]
sources: [https://perfectmediaserver.com/02-tech-stack/nixos/]
---

# 🏗️ ABC-Storage-Tiering: Das Hybride Storage-Manifest

Dieses System kombiniert das Beste aus zwei Welten: Die absolute Datensicherheit von ZFS und die einfache Skalierbarkeit von MergerFS.

## 🔴 Tier A: Critical Data (ZFS Native)
- **Inhalt:** Unersetzbare Daten (Fotos, Dokumente, Sops-Secrets, DBs).
- **Technik:** ZFS Mirror oder RaidZ.
- **Vorteil:** Schutz vor Bit-Rot, atomare Snapshots, einfache Remote-Replikation via Syncoid.

## 🔵 Tier C: Bulk Media (MergerFS + SnapRAID)
- **Inhalt:** Ersetzbare Medien (Linux ISOs, Filme, Serien).
- **Technik:** MergerFS pooling von Mismatch-Drives + SnapRAID Parität.
- **Vorteil:** Kosteneffizient, jede Platte einzeln lesbar, kein Rebuild-Stress.

## 🧩 Die Hybride Synthese (The Master Mount)
Wir mergen die ZFS-Datasets und die JBOD-Platten zu einem einzigen logischen Pfad (\`/mnt/storage\`).

### NixOS Implementierung:
\`\`\`nix
fileSystems."/mnt/storage" = {
  # Wir kombinieren die JBOD-Disks und das ZFS-Dataset "fuse"
  device = "/mnt/disk*:/mnt/tank/fuse";
  fsType = "fuse.mergerfs";
  options = [
    "defaults"
    "allow_other"
    "use_ino"
    "cache.files=off"
    "moveonenospc=true"
    "category.create=mfs" # Füllt alle Platten gleichmäßig
    "dropcacheonclose=true"
    "minfreespace=250G"
  ];
};
\`\`\`

## 🛡️ SRE-Regeln für das Tiering
1.  **Naming-Isolation:** Halte Ordnernamen auf ZFS und JBOD eindeutig, damit MergerFS weiß, wo neue Dateien landen sollen (Create-Policy-Logic).
2.  **SnapRAID-Sync:** Ein täglicher systemd-Timer triggert den SnapRAID-Sync für den JBOD-Teil (Tier C).
3.  **Sanoid-Snapshots:** ZFS-Datasets (Tier A) werden stündlich via Sanoid gesichert.