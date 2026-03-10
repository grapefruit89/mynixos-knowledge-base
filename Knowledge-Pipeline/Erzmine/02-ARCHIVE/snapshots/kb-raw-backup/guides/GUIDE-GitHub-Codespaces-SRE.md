---
title: ☁️ GitHub Codespaces (The Mobile Command Center)
category: architecture/automation
status: [ACTIVE-SSoT]
capabilities: [cloud-ide, nix-integration, prebuild-performance, remote-management]
sources: [GitHub Codespaces Documentation, DevContainer Standard]
---

# ☁️ GitHub Codespaces: Deine IDE in der Cloud

In mynixos nutzen wir Codespaces als redundante, mobile Entwicklungsumgebung. Sie ermöglicht SRE-Eingriffe von jedem Gerät mit Browser.

## 🏛️ 1. Das Konzept (DevContainer)
Wir deklarieren unsere Entwicklungsumgebung in \`.devcontainer/devcontainer.json\`.
- **Nix-Support:** Wir nutzen das offizielle Nix-Feature für Codespaces.
- **Tools:** Alle SRE-Werkzeuge (sops, git, age, fwknop) sind vorinstalliert. ✅

## ⚡ 2. Prebuilds (Zero-Latency)
Wir aktivieren Prebuilds, damit der Cloud-Rechner sofort einsatzbereit ist.
- **Workflow:** GitHub baut das Environment bei jedem Push im Hintergrund.
- **SRE-Vorteil:** Im Notfall zählt jede Sekunde. Ein Codespace, der sofort da ist, schlägt jede lokale Installation.

## 🔑 3. Secret Management
GitHub Codespaces können auf deine Repository-Secrets (Kapitel 73) zugreifen.
- **Anwendung:** Automatisches Entsperren von Sops-Files im Cloud-Editor via injizierter Age-Keys.

## 🚀 SRE-Anwendung
Codespaces sind der Fallback, falls dein lokaler Laptop defekt ist oder du keinen Zugriff auf deine gewohnte Arbeitsumgebung hast. Sie garantieren die **Fortführung der Operationen** unter allen Umständen.