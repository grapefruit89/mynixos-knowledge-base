---
title: ⚡ CI/CD, Caching & Performance Optimization
category: architecture/automation
status: [ACTIVE-SSoT]
capabilities: [binary-caching, evaluation-acceleration, nix-action]
sources: [https://docs.determinate.systems/magic-nix-cache]
---

# ⚡ Performance: Schluss mit dem Evaluations-Flaschenhals

Determinate Systems bietet die Werkzeuge für blitzschnelle Workflows.

## 🚀 Magic Nix Cache
In unseren GitHub Actions oder lokalen Build-Pipelines nutzen wir den Magic Nix Cache.
- **Zero-Config:** Erkennt automatisch alle Store-Pfade.
- **Background Upload:** Kappt keine Build-Prozesse durch langsame Uploads.

## 📊 Evaluations-Beschleunigung
- **Parallel Evaluation:** Wir nutzen die parallele Evaluator-Engine, um die Wall-Clock-Time bei komplexen \`nixos-rebuild\` Prozessen zu minimieren.
- **Lazy Trees:** Reduziert den Speicherverbrauch während der Nix-Evaluation massiv.