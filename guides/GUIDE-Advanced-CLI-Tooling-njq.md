---
title: 🛠️ njq: Nix-Powered JSON Processing (Layer 00-core)
category: architecture/tooling
status: [PROPOSED]
capabilities: [json-filtering, nix-syntax, cli-efficiency, log-analysis]
sources: [r/Nix, njq GitHub]
---

# 🛠️ njq: JSON-Verarbeitung mit Nix-Power

In mynixos nutzen wir \`njq\`, um strukturierte Daten (Logs, API-Antworten) direkt auf der Kommandozeile mit der vertrauten Nix-Syntax zu filtern.

## 🏛️ 1. Warum njq statt jq?
- **Konsistenz:** Du nutzt die gleiche Sprache für dein System-Design und deine Daten-Analyse.
- **Mächtigkeit:** Nutze Nix-Funktionen (map, filter, etc.) auf beliebige JSON-Daten.
- **Headless:** Ein winziges CLI-Tool ohne Abhängigkeiten. ✅

## ⚙️ 2. Anwendungsbeispiel (SRE-Workflow)
Analyse der Caddy-Logs:
\`\`\`bash
cat /var/log/caddy/access.log | njq 'map (x: { ip = x.remote_ip; status = x.status })'
\`\`\`
- **Ergebnis:** Chirurgisch präzise Extraktion von Daten ohne komplexe Regex-Hölle.

## 🚀 SRE-Vorteil
njq erhöht deine operative Geschwindigkeit. Da du Nix bereits beherrschst, entfällt die Lernkurve für andere Query-Sprachen. Es ist das "Aviation-Grade" Skalpell für Daten.