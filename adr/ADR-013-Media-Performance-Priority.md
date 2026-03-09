---
title: ADR-013: Media Performance Priority (High-Priority Standard)
status: [ACCEPTED]
category: architecture/decision
capabilities: [real-time-priority, smooth-streaming, systemd-resource-control]
sources: [Systemd Resource Control, SRE Best Practices]
---

# 🏛️ ADR-013: Aktive Priorisierung von Jellyfin

## Kontext
Um Ruckler beim Streaming (insbesondere 4K) zu eliminieren, muss Jellyfin gegenüber anderen Systemdiensten priorisiert werden.

## Entscheidung
Wir implementieren eine aggressive Priorisierung für den Jellyfin-Dienst:
1.  **CPU-Vorrang:** \`Nice=-7\` (Hohe Priorität) und \`CPUWeight=500\` (Garantierte Zyklen).
2.  **I/O-Vorrang:** \`IOWeight=500\` (Bevorzugter Zugriff auf Festplatten).
3.  **Survivor-Status:** \`OOMScoreAdjust=-500\` (Schutz vor dem OOM-Killer).
4.  **Hardware-Lock:** Direkter Zugriff auf \`/dev/dri/renderD128\` mit höchster Priorität.

## Begründung
- **User Experience:** Ein verzögerungsfreier Stream ist das primäre Ziel des Servers.
- **Ressourcen-Effizienz:** Da Jellyfin via QuickSync (GPU) arbeitet, belasten diese Priorisierungen die CPU im Normalfall kaum, verhindern aber Ruckler, falls Hintergrund-Tasks (z.B. Backups) CPU-Spitzen verursachen.

## Konsequenz
Die \`serviceConfig\` in \`modules/40-media/jellyfin.nix\` wird mit diesen Werten gehärtet.