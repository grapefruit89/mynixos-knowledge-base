---
title: ADR-006: Storage Cluster Strategy (From Single-Node to Distributed)
status: [PROPOSED]
category: architecture/decision
capabilities: [zfs-pools, distributed-storage, high-availability]
sources: [https://secretmine.de/storage-cluster-der-plan/, ironicbadger pms-wiki]
---

# 🏛️ ADR-006: Storage-Cluster Strategie

## Kontext
Wir benötigen eine Speicherlösung, die mit dem Tower (Fujitsu Q958) startet, aber später auf mehrere Knoten skaliert werden kann.

## Entscheidung
Wir implementieren eine evolutionäre Cluster-Strategie:
1.  **Start (Single-Node):** Wir nutzen **ZFS (Zettabyte File System)** als lokalen Cluster-Manager. Alle Platten werden in vdevs und Pools organisiert.
2.  **Expansion (Multi-Node):** Bei Hinzunahme weiterer Hardware evaluieren wir **Ceph** oder **MinIO**, um einen echten verteilten Storage-Cluster aufzubauen.
3.  **Hybrid-Schicht:** Wir nutzen **MergerFS**, um lokale ZFS-Pools und verteilte Netzwerk-Shares zu einem logischen Mountpoint zusammenzuführen.

## Begründung
- **Sicherheit:** ZFS schützt vor schleichendem Datenverlust (Bit-Rot).
- **Flexibilität:** MergerFS erlaubt das Einbinden von ungleich großen Platten ohne Datenverlust.
- **Zukunftssicherheit:** Der Wechsel zu Ceph ist möglich, da NixOS beide Technologien nativ unterstützt.

## Konsequenz
In \`modules/00-core/storage.nix\` wird die ZFS-Pool-Struktur deklariert. Wir bereiten den Tower als "Knoten 1" eines potenziellen Clusters vor.