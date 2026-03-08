---
title: Dendritische Modularisierung (Modularization Bible)
category: architecture/framework
capabilities: [modular-flakes, flake-parts-expert, dendritic-structure]
sources: [https://github.com/mightyiam/dendritic]
---

# 🌳 Dendritische Modularisierung: Die mynixos Bibel

Das Dendritische Pattern ist die Kunst, Nix-Konfigurationen so zu zerlegen, dass sie wartungsfrei und portabel sind.

## 📁 Die Goldene Ordnerstruktur
Jede Datei in mynixos ist ein **Top-Level Modul**.

### systems/
*Hier liegen nur die Host-spezifischen Zuweisungen.*
- `tower/default.nix`: Welche Module nutzt der Tower? Welche IP? Welche Hardware?

### modules/
*Hier liegt die Logik.*
- `services/caddy.nix`: Die komplette Caddy-Logik in einer Datei.
- `security/sops.nix`: Die Sicherheits-Infrastruktur.

## 🧩 Das Flake-Parts Prinzip
Wir nutzen `flake-parts`, um die Evaluation zu modularisieren. 
- **Regel:** Kein Modul darf `specialArgs` erwarten. Alles kommt über die Top-Level `config`.

## 🛡️ "One Feature, One File"
Jede Datei implementiert genau ein Feature über alle Konfigurationen hinweg (NixOS, Home-Manager).
