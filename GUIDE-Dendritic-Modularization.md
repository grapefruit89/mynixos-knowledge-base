---
title: 🌳 Dendritische Modularisierung (Definitive Edition v7.0)
category: architecture/framework
status: [ACTIVE-SSoT]
supersedes: [Architecture-NIXHOME-Dendritic-Structure.md, dendritic-blueprint.md, flake-parts.md]
sources: [https://github.com/mightyiam/dendritic, https://github.com/hercules-ci/flake-parts]
---

# 🌳 Dendritische Modularisierung: Das mynixos Manifest

Dies ist das ultimative Architektur-Dokument für die Struktur deines Systems. Wir folgen dem "Aviation-Grade" Dendritic Pattern.

## 🏛️ Kern-Philosophie
"Every file is a module." Wir trennen Logik strikt von Zuweisung.

## 📁 Repository-Layout (Final Standard)
```text
mynixos/
├── flake.nix                # Top-Level Entry (Flake-Parts)
├── systems/                 # Host-spezifische Konfigurationen
│   └── tower/               # Dein Unraid Tower
├── modules/                 # Wiederverwendbare Dendriten (Logik)
│   ├── services/            # Caddy, Arion, etc.
│   ├── security/            # Sops, Jails
│   └── core/                # System-Basics
└── secrets/                 # Sops-Tresor & Keys
```

## 🧩 Flake-Parts Integration
Werte werden über Top-Level `options` definiert, niemals über `specialArgs` durchgereicht.

## 🛠️ Auto-Discovery
Wir nutzen `import-tree`, um neue Module im `modules/` Ordner automatisch zu laden.
