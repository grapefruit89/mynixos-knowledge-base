---
title: Enterprise Nix Standards (Determinate Systems)
category: architecture/enterprise
capabilities: [enterprise-stability, binary-caching, flake-checking]
sources: [https://github.com/DeterminateSystems/nix-installer, https://github.com/DeterminateSystems/flake-checker]
---

# 🏢 Enterprise Nix: Die Determinate Standards

Für ein produktives System (Tower) reichen Community-Standards oft nicht aus. Wir integrieren Enterprise-Grade Werkzeuge von Determinate Systems.

## 🚀 Der Determinate Installer
Wir nutzen den modernen Installer, der Flakes und Multi-User Support nativ und sicher konfiguriert.
- **Vorteil:** Keine manuellen Hacks in der `nix.conf` nötig.

## ⚡ Magic Nix Cache
In unseren Deployment-Pipelines nutzen wir den Magic Nix Cache.
- **Regel:** Jeder Build-Artefakt wird automatisch gecached, um Re-Evaluations zu minimieren.

## 🔍 Flake Health Checks (`flake-checker`)
Wir prüfen unsere `flake.lock` regelmäßig auf:
- Veraltete Nixpkgs-Versionen.
- Bekannte Sicherheitslücken.
- Inkompatible Input-Kombinationen.

## 🌐 FlakeHub
Wir bevorzugen verifizierte Flakes von FlakeHub für kritische Infrastruktur-Komponenten.
