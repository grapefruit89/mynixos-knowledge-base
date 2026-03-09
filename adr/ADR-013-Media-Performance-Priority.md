---
title: ADR-013: Universal Media Performance Priority (A/V-Law)
status: [ACCEPTED]
category: architecture/decision
capabilities: [real-time-audio-video, smooth-streaming, systemd-resource-control]
sources: [SRE Best Practices, Audio/Video Buffer Management]
---

# 🏛️ ADR-013: Das Universal-Gesetz für Audio/Video-Priorisierung

## Kontext
Zeitkritische Dienste (Streaming, Audio, Podcasts) erfordern konstante Ressourcen, um Latenzen (Ruckler/Aussetzer) zu vermeiden.

## Entscheidung
Wir implementieren eine systemweite Priorisierung für den gesamten **Media-Layer (40)**:
1.  **Betroffene Dienste:** Jellyfin, Navidrome, Audiobookshelf.
2.  **CPU-Vorrang:** \`Nice=-10\` (Höchste App-Priorität) und \`CPUWeight=1000\` (Maximale Gewichtung).
3.  **I/O-Vorrang:** \`IOWeight=1000\` (Priorisierter Festplattenzugriff für Buffering).
4.  **Survival-Mandat:** \`OOMScoreAdjust=-800\` (Diese Dienste werden fast niemals vom OOM-Killer beendet).

## Begründung
- **Aviation-Grade Quality:** Musik und Video dürfen niemals ruckeln.
- **Dynamic Throttling:** Hintergrund-Dienste (Layer 80/Backup) treten automatisch zurück, sobald ein Media-Stream Last erzeugt.

## Konsequenz
In allen Media-Dendriten (\`modules/40-media/*.nix\`) werden diese Parameter als Standard in die \`serviceConfig\` aufgenommen.