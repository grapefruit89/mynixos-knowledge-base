---
title: ADR-013: Media Performance Priority (Anti-Stuttering)
status: [ACCEPTED]
category: architecture/decision
capabilities: [smooth-streaming, task-prioritization, systemd-tuning]
sources: [Jellyfin Best Practices, Systemd Resource Control Docs]
---

# 🏛️ ADR-013: Priorisierung von Medien-Streaming

## Kontext
Bei Nutzung von Socket-Activation für Jellyfin besteht das Risiko, dass Hintergrund-Tasks (Bibliothek-Scans) beim Aufwachen die Streaming-Performance beeinträchtigen.

## Entscheidung
Wir implementieren eine strikte Ressourcen-Hierarchie für Medien-Dienste:
1.  **CPU/IO Throttling:** Hintergrund-Dienste in Jellyfin werden via systemd auf die niedrigste Priorität gesetzt (\`Nice=15\`, \`IOSchedulingPriority=7\`).
2.  **Scan-Policy:** Automatische Scans beim Start werden deaktiviert. Scans erfolgen ausschließlich über einen nächtlichen Timer (Layer 80).
3.  **Transcoding Priority:** Der ffmpeg-Prozess (QuickSync) erhält Echtzeit-Priorität gegenüber anderen App-Logiken.

## Begründung
- **User Experience:** Ein flüssiger Stream ist wichtiger als aktuelle Metadaten während des Schauens.
- **Ressourcen-Schonung:** Verhindert Lastspitzen beim "Aufwachen" des Dienstes.

## Konsequenz
In \`modules/40-media/jellyfin.nix\` werden die systemd \`serviceConfig\` Parameter entsprechend angepasst.