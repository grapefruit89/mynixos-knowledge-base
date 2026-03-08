---
title: Container-Symbiose (Arion Integration)
category: architecture/services
capabilities: [declarative-containers, docker-compose-integration, arion]
sources: [https://github.com/hercules-ci/arion]
---

# 🐳 Container-Symbiose: Arion & Docker

Arion ist die Brücke zwischen der Docker-Compose Welt und der deklarativen NixOS Welt.

## 🚀 Warum Arion?
- **Docker-Compose mit Nix:** Wir definieren Container-Strukturen in Nix, generieren aber Docker-Compose YAMLs.
- **Nix-Build Images:** Wir können Docker-Images direkt in Nix bauen und via Arion deployen.

## 📁 Struktur eines Arion-Dendriten
Ein Arion-Dienst in mynixos liegt in `modules/services/<name>.nix` und nutzt das `arion.nixosModules.arion` Modul.

## 🧩 Beispiel-Konfiguration
`mynixos.services.arion.enable = true;`
