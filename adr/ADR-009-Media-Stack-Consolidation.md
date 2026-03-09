---
title: ADR-009: Media Stack Consolidation (Simplicity over Complexity)
status: [ACCEPTED]
category: architecture/decision
capabilities: [sqlite-reliability, service-bundling, zero-maintenance]
sources: [nixarr, user-feedback, Internal SRE Audit]
---

# 🏛️ ADR-009: Der konsolidierte Media Stack (Simplicity Edition)

## Kontext
Wir haben die Wahl zwischen PostgreSQL und SQLite für den ARR-Stack analysiert.

## Entscheidung
Wir nutzen **SQLite** als Standard-Datenbank für alle ARR-Dienste (Sonarr, Radarr, Lidarr, Prowlarr).

## Begründung (The Simplicity Wins)
1.  **Zero Maintenance:** Keine Datenbank-Administration nötig. NixOS-Module konfigurieren SQLite automatisch "out-of-the-box".
2.  **Resource Efficiency:** Einsparung des PostgreSQL-Daemon Overheads (RAM/CPU).
3.  **Backup Ease:** Einfache Datei-basierte Sicherung der Datenbank-Files (\`.db\`) im App-Verzeichnis.

## Bündelung
Wir behalten das Systemd-Target \`media-stack.target\` bei, um alle Dienste gleichzeitig steuern zu können.

## Konsequenz
In \`modules/40-media/*.nix\` wird kein PostgreSQL-Bezug für ARR-Apps implementiert. Wir folgen dem Pfad von \`nixarr\`.