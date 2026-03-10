---
title: ⚙️ Nixpkgs Engine Mastery (Architecture Core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [kernel-management, package-overlays, by-name-standard]
sources: [nixpkgs/pkgs/top-level/]
---

# ⚙️ Nixpkgs Engine: Unter der Haube

Um mynixos auf Aviation-Grade Level zu betreiben, müssen wir verstehen, wie der Engine-Room von Nixpkgs funktioniert.

## 🏛️ 1. Kernel Management (Layer 00-core)
In `engine-linux-kernels.nix` sehen wir, wie Kernel deklariert werden.
- **Pattern:** Wir können für den Tower gezielt den `linuxPackages_latest` oder `linuxPackages_hardened` wählen.

## 🧩 2. Der By-Name Standard
Nixpkgs nutzt das `pkgs/by-name` Pattern. Wir kopieren diesen Standard für unsere eigenen Pakete in `mynixos/pkgs/`.
- **Vorteil:** Automatische Erkennung von Paketen ohne manuelle Imports in `all-packages.nix`.

## ⚙️ 3. Globale Konfiguration (`config.nix`)
Hier deklarieren wir systemweite Nixpkgs-Einstellungen:
- `allowUnfree = true;` (Nötig für Intel-Treiber).
- `permittedInsecurePackages = [ ... ];` (Nur im Notfall!).
