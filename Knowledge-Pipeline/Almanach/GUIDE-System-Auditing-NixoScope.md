---
title: System Auditing & Visualisierung (NixoScope Standard)
category: architecture/sre-tools
capabilities: [auditing, dependency-visualization, integrity-checks]
sources: [https://github.com/giomf/NixoScope]
---

# 🔍 System Auditing: Die Dendriten visualisieren

Ein Aviation-Grade System muss transparent sein. Wir nutzen NixoScope, um die Modul-Abhängigkeiten sichtbar zu machen.

## 🚀 Warum Auditing?
- **Komplexitäts-Kontrolle:** Erkennt sofort, wenn das Dendritische Pattern durch zu viele Quer-Importe verwässert wird.
- **Fehlersuche:** Zeigt genau, welches Modul eine bestimmte Option definiert oder überschreibt.

## 🛠️ Anwendung (SRE Tor 5 Check)
Um den aktuellen System-Graph zu generieren:
`nix run github:giomf/nixoscope -- --option "flake.modules"`

## 🛡️ SRE-Integrität
Regelmäßige Audits mit NixoScope stellen sicher, dass die **Dendritische Integrität** gewahrt bleibt und keine monolithischen Strukturen "durch die Hintertür" eingeführt werden.
