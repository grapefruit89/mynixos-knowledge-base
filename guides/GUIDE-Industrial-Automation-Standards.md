---
title: 🏭 Industrial Automation Standards (numtide Patterns)
category: architecture/automation
status: [ACTIVE-SSoT]
capabilities: [unified-formatting, build-filtering, efficient-development]
sources: [https://github.com/numtide/treefmt, https://github.com/numtide/nix-filter]
---

# 🏭 Industrial Automation: Der SRE Standard

Ein Aviation-Grade System muss wartbar sein. Wir nutzen industrielle Werkzeuge von numtide, um Konsistenz und Performance zu garantieren.

## 🚀 Unified Formatting (\`treefmt\`)
Wir nutzen \`treefmt\`, um alle Quellcodedateien im Repository einheitlich zu formatieren.
- **Vorteil:** Keine unnötigen Git-Diffs durch Formatierungs-Kämpfe.
- **Integration:** Ein \`pre-commit\` Hook stellt sicher, dass nur purer Code in die Knowledge-Base oder das Config-Repo gelangt.

## ⚡ Build Optimization (\`nix-filter\`)
Große Repositories verlangsamen den Nix-Evaluations-Prozess. Wir nutzen \`nix-filter\`, um nur die Dateien in den Build-Kontext zu laden, die wirklich gebraucht werden.
- **Ergebnis:** Schnellere \`nixos-rebuild\` Zeiten auf dem Tower.

## 🛠️ DevShell Integration
Die numtide Tools sind fester Bestandteil unserer \`devShell\` in mynixos.