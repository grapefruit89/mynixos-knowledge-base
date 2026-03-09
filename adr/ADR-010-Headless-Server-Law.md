---
title: ADR-010: Headless Server Law (No-GUI Mandate)
status: [ACCEPTED]
category: architecture/decision
capabilities: [resource-efficiency, security-hardening, headless-operations]
sources: [User Mandate, Manifest v7.1]
---

# 🏛️ ADR-010: Das Headless-Gesetz

## Kontext
Wir bauen eine hocheffiziente mynixos Distribution für den Fujitsu Q958 Tower. Ressourcen müssen für Dienste und Daten reserviert bleiben.

## Entscheidung
Die Installation von grafischen Oberflächen (GUIs) und deren Abhängigkeiten ist **STRIKT VERBOTEN**.
- **Verbotene Frameworks:** X11, Wayland, Qt, GTK, Electron (außer headless).
- **Verbotene Apps:** Desktop-Newsreader (QuiteRSS), Desktop-Browser, Theming-Tools für Desktops.
- **SSoT-Ersatz:** Alle Dienste müssen via Web-UI, CLI oder API (REST/WebSocket) bedienbar sein.

## Begründung
- **Efficiency:** Wegfall der massiven Overhead-Kosten von Desktop-Umgebungen (RAM/CPU).
- **Security:** GUIs erhöhen die Angriffsfläche (Attack Surface) drastisch. Ein Server ohne X11 ist sicherer.
- **Maintenance:** Keine Frickelei mit Grafik-Treibern (außer iHD für Transcoding).

## Konsequenz
In \`modules/90-policy/no-gui.nix\` wird eine Assertion implementiert, die den Build abbricht, falls GUI-Komponenten erkannt werden.