---
title: ADR-009: Media Stack Consolidation (PostgreSQL & Systemd Targets)
status: [ACCEPTED]
category: architecture/decision
capabilities: [database-consolidation, service-bundling, systemd-targets]
sources: [ARR-Stack Documentation, NixOS Systemd Manual]
---

# 🏛️ ADR-009: Der konsolidierte Media Stack

## Kontext
Wir wollen den ARR-Stack (Sonarr, Radarr, Lidarr, Prowlarr) effizienter verwalten und die Datenbank-Infrastruktur vereinheitlichen.

## Entscheidung
1.  **Datenbank:** Alle ARR-Dienste werden konsequent an den zentralen **PostgreSQL-Dendriten** (Layer 20-server) angebunden. SQLite wird vermieden.
2.  **Bündelung:** Wir implementieren ein Systemd-Target \`media-stack.target\`.
3.  **Abhängigkeiten:** Alle Dienste bekommen eine \`partOf = [ "media-stack.target" ];\` und \`requires = [ "postgresql.service" ];\` Anweisung.

## Begründung
- **Wartbarkeit:** Backups werden durch PostgreSQL-Zentralisierung drastisch vereinfacht.
- **Orchestrierung:** Ein einziger Befehl steuert den gesamten Stack (\`systemctl start media-stack.target\`).
- **Performance:** PostgreSQL skaliert besser als multiple SQLite-Instanzen auf dem Tower.

## Konsequenz
In \`modules/40-media/*.nix\` wird die Datenbank-Konfiguration auf PostgreSQL umgestellt. Wir definieren das globale Target in \`modules/40-media/default.nix\`.