---
title: "Strategy: Determinate Systems Architectural Deep-Dive (Phase 2)"
category: "learnings"
tags: [nix, architecture, semver, bootstrap, intel, sRE]
id: "NIXH-STRAT-006"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["Determinate Systems GitHub Org (fh, nix-installer, determinate)"]
---

# Strategy: Determinate Systems Architectural Deep-Dive (Phase 2)

## 1. User Layer (KISS)
Dieses Dokument vertieft unsere technologische Allianz mit Determinate Systems. Wir haben gelernt, wie wir dein System noch stabiler machen (durch intelligente Versionierung), wie wir Fehler beim Installieren auf deinem Fujitsu-Server vermeiden und wie wir Konfigurations-Dateien noch sauberer trennen. Das Ziel ist ein „Self-Healing“ Homelab, das sich fast von selbst wartet.

## 2. Technical Layer (Aviation-Grade)

### Semantische Flake-Steuerung (via FlakeHub Patterns)
*   **Problem:** Starre Bindung an  führt oft zu unerwarteten Breaking Changes.
*   **Lösung:** Einführung von **SemVer-Ranges** für Flake-Inputs. Wir nutzen das Pattern von , um Abhängigkeiten flexibel, aber sicher zu definieren.
*   **Vorteil:** Automatische Sicherheits-Updates innerhalb einer stabilen Version, ohne dass wir manuell eingreifen müssen.

### Zero-Touch Bootstrap auf Intel/UEFI (Q958)
Basierend auf einem Audit der  Issues optimieren wir den Erst-Installations-Prozess:
*   **Fix:** Erzwingung der experimentellen Features () bereits im Installer-Aufruf.
*   **EFI-Safe:** Vermeidung von Schreibzugriffen auf NVRAM während der Build-Phase zur Schonung des i3-9100 Mainboards.

### Advanced Service Orchestration (Dendritic Pattern)
Wir übernehmen das Struktur-Muster des offiziellen  Moduls:
*   **XDG Alignment:** Konfigurations-Dateien für Dienste werden in  deklariert.
*   **Systemd Injection:** Diese Dateien werden via  oder  in die isolierten Dienste injiziert.
*   **Vorteil:** Die Nix-Evaluierung bleibt schnell, da wir nur kleine JSON-Dateien statt riesiger Nix-Attribute-Sets manipulieren.

## 3. Reasoning Layer (History)

### [ADR-077] Migration to SemVer-based Flake Inputs
*   **Status:** In Planung (V6.x).
*   **Kontext:** Aktuell sind alle Module hart auf einen Branch gepinnt.
*   **Entscheidung:** Umstellung auf semantische Versionierung für kritische Infrastruktur-Inputs.
*   **Begründung:** Maximierung der Uptime durch Vermeidung inkompatibler Major-Updates während automatisierter Rebuilds.

---
**Community-Abgleich:** Synchronisiert mit den Enterprise-Best-Practices von FlakeHub und dem Determinate Nix Installer.
