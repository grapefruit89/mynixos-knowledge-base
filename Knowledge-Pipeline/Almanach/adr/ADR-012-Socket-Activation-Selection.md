---
title: ADR-012: Selection Criteria for Socket Activation (Safety First)
status: [ACCEPTED]
category: architecture/decision
capabilities: [pragmatic-efficiency, connectivity-guarantee, security-hardening]
sources: [User Feedback, Connectivity Audit]
---

# 🏛️ ADR-012: Pragmatische Socket-Activation (v2.0)

## Kontext
Wir haben SSH fälschlicherweise für Socket-Activation vorgesehen. 

## Entscheidung
**SSH wird STRIKT von der Socket-Activation ausgeschlossen.** Es bleibt permanent aktiv (\`services.openssh.enable = true;\`).

## Begründung (The Safety Mandate)
- **Erreichbarkeit:** Das Risiko, sich bei einem Fehler in der Socket-Logik physisch vom Tower auszusperren, ist inakzeptabel.
- **Minimaler Gewinn:** Die Ersparnis von ~5MB RAM steht in keinem Verhältnis zur Gefahr des Kontrollverlusts.

## Konsequenz
Nur interaktive Schwergewichte (Jellyfin, Paperless) werden bei Bedarf gestartet.