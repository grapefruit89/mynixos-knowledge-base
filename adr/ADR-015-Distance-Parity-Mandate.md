---
title: ADR-015: Distance Over Local Parity (The anti-RAID Mandate)
status: [ACCEPTED]
category: architecture/decision
capabilities: [offsite-recovery, 3-2-1-rule, state-minimization]
---

# 🏛️ ADR-015: Distanz ist die bessere Parität

## Kontext
Lokale Redundanz (RAID/SnapRAID) schützt nicht gegen Feuer, Diebstahl oder Headcrash-Serien, erhöht aber die Komplexität und verhindert HDD-Spindown.

## Entscheidung
Wir verzichten auf jegliche lokale Redundanz (RAID/Parity) und investieren die Ressourcen in **geografische Distanz**:
1. **Tier A (State):** Muss unter 10GB bleiben. Sicherung via Restic zu S3.
2. **Tier A++ (Fotos):** 3-2-1 Strategie. Zwei geografisch getrennte Cloud-Ziele plus lokaler State.
3. **Tier C (Media):** Akzeptierter Totalverlust bei Hardware-Defekt.

## Begründung
- **KISS:** Keine RAID-Rebuilds, keine Paritäts-Berechnungen.
- **Recovery:** Ein S3-Bucket ist schneller wiederhergestellt als ein korruptes RAID-Array.
- **Efficiency:** Maximaler Spindown für HDDs garantiert.

## Konsequenz
Wir implementieren eine strikte State-Diät (Logging-Limits, Thumbnail-Offloading), um die 10GB Grenze für Tier A physisch zu garantieren.