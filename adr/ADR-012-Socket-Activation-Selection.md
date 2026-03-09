---
title: ADR-012: Selection Criteria for Socket Activation
status: [ACCEPTED]
category: architecture/decision
capabilities: [pragmatic-efficiency, resource-management, systemd-hardening]
sources: [Internal SRE Audit, User Feedback]
---

# 🏛️ ADR-012: Pragmatische Socket-Activation

## Kontext
Wir haben die Liste unserer Dienste auf das Potenzial zur Socket-Activation (Wake-on-Request) geprüft.

## Entscheidung
Wir implementieren Socket-Activation **NUR** bei Diensten, die:
1.  Einen signifikanten RAM-Footprint (>100MB) im Idle haben.
2.  Nicht für Hintergrund-Scans oder Echtzeit-Föderation (z.B. Matrix) permanent wach sein müssen.
3.  Keine kritischen Infrastruktur-Basisdienste (z.B. Caddy, DNS, Auth) sind.

## Selektions-Ergebnis
- **Aktiviert:** Jellyfin, Paperless, Audiobookshelf, SSH.
- **Dauerhaft aktiv:** Caddy, AdGuardHome, PocketID, Valkey, Matrix-Conduit, Fail2ban.
- **Prüffall (Background):** ARR-Stack (Sonarr etc.) wird im Normalbetrieb dauerhaft ausgeführt, um automatische Downloads nicht zu verpassen.

## Begründung
- **Stabilität:** Infrastruktur-Dienste müssen sofort antworten können (Latenz-Vermeidung).
- **Nutzen:** Bei winzigen Go/Rust-Binaries (<50MB RAM) ist die Ersparnis vernachlässigbar im Vergleich zum Risiko von Timeouts.

## Konsequenz
In \`modules/00-core/systemd.nix\` wird nur für die "Aktiviert"-Liste das Socket-Interface konfiguriert.