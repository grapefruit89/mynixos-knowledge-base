---
title: Dendritic Blueprint (mynixos Standard)
category: architecture/framework
capabilities: [modular-flakes, flake-parts-expert, dendritic-structure]
sources: [https://github.com/mightyiam/dendritic, https://github.com/mightyiam/infra]
---

# 🌳 Dendritic Blueprint: mynixos Evolution

Basierend auf den Shahar Or (@mightyiam) Prinzipien bauen wir mynixos modular auf.

## 📁 Ordnerstruktur (Dendritic Pattern)

1.  **systems/**: Host-spezifische Konfigurationen (Tower, Laptop, Server).
2.  **modules/**: Wiederverwendbare NixOS- und Home-Manager-Module.
3.  **pkgs/**: Eigene Pakete, die noch nicht in nixpkgs sind.
4.  **secrets/**: Sops-verschlüsselte Daten (Veredelt durch sops-nix).

## 🧩 Flake-Parts Integration

Jeder Ordner enthält eine `default.nix`, die via `flake-parts` eingebunden wird. Das verhindert monolithische Dateien.

## 🛠️ DevShell

Die DevShell stellt die Mining-Werkzeuge (sops, arion, nix-index) zur Verfügung.
