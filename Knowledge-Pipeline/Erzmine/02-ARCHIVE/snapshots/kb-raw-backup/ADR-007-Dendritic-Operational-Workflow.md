---
id: ADR-007
title: Dendritic Operational Workflow (Shell & MOTD)
status: accepted
date: 2026-03-10
tags: [shell, bash, aliases, motd, flakes, workflow, sre]
---

# ADR-007: Dendritic Operational Workflow (Shell & MOTD)

## 1. USER LAYER (KISS)
Ein SRE (Site Reliability Engineer) braucht eine Umgebung, in der er nicht "im Dunkeln stolpert". Wenn du dich per SSH auf deinem Fujitsu Q958 einloggst, wirst du sofort mit einem Statusbericht (MOTD) begrüßt, der dir zeigt, ob das System gesund ist und welche Befehle (Aliase) dir zur Verfügung stehen. Wir nutzen kurze, einprägsame Kürzel wie `nsw` (rebuild switch) oder `nclean` (Aufräumen), um die tägliche Arbeit mit NixOS effizient und sicher zu machen.

## 2. TECHNICAL LAYER (Specification)

### Standardisierte Aliase (Flake-Aware)
Alle System-Befehle sind auf die Flake-Architektur (`.#q958`) optimiert.

#### Zentrale Aliase (`shell.nix`):
| Alias | Befehl | Funktion |
| :--- | :--- | :--- |
| **`nsw`** | `sudo nixos-rebuild switch --flake .#q958` | System-Update aktivieren |
| **`ntest`** | `sudo nixos-rebuild test --flake .#q958` | Test-Build (ohne Boot-Eintrag) |
| **`nup`** | `nix flake update` | Abhängigkeiten aktualisieren |
| **`nclean`** | `sudo nix-env -p /nix/... --delete-generations +5 && nix-store --gc` | Müll entfernen (letzte 5 behalten) |
| **`nconf`** | `cd ~/mynixos && vscodium .` | Konfiguration bearbeiten |

### Dynamisches MOTD (Message of the Day)
Das MOTD wird über `services.openssh.banner` oder ein interaktives Shell-Skript realisiert, das beim Login folgende Informationen anzeigt:
- **Hostname & IP:** Eindeutige Identifikation des Hosts.
- **System-Status:** Auslastung (CPU/RAM), aktive Systemd-Fehler.
- **Workflow-Hilfe:** Eine kurze Tabelle der wichtigsten Aliase (`nsw`, `ntest`).

### Der TUI-Stack (Terminal User Interface)
Für maximale Effizienz nutzen wir spezialisierte Rust/Go-basierte TUIs, die den klassischen UNIX-Tools überlegen sind:

| Tool | Zweck | Überlegenheit gegenüber Standard |
| :--- | :--- | :--- |
| **`btop`** | System-Monitoring | Grafische CPU/RAM/Netz-Anzeige, interaktiver Prozess-Kill. |
| **`yazi`** | File Management | Async I/O, extrem schnell, Bildvorschau, Plugin-System. |
| **`lazygit`** | Git Workflow | Visualisierung von Branches und Staging ohne komplexe Befehle. |
| **`delta`** | Diff Viewer | Syntax-Highlighting für `nix-diff` und `git diff`. |
| **`zellij`** | Multiplexer | Intuitive Tabs/Panes, kein Auswendiglernen von Shortcuts nötig. |
| **`fzf`** | Fuzzy Finding | Blitzschnelle History-Suche (Strg+R) und Dateisuche. |

### Dynamisches MOTD (Aviation-Grade Standard)
Das MOTD ist kein statischer Text mehr, sondern ein dynamisches Skript, das Echtzeitdaten liefert.

#### Anzeige-Mandat:
1.  **Host-Identity:** Fujitsu Q958 Identifikation (Host + LAN-IP + Tailscale-IP).
2.  **Resource-Status:** Aktuelle Load, Disk-Usage (Root) und Memory-Pressure.
3.  **Service-Health:** Visueller Check (✓/✗) für Traefik, SSH, Tailscale und Jellyfin.
4.  **Workflow-Assistent:** Direkte Liste der wichtigsten Aliase (`nsw`, `ntest`, `nclean`).

## 3. REASONING LAYER (ADR)

### Warum Rust-basierte Tools (yazi, delta, btop)?
Rust bietet Speicher-Sicherheit und enorme Performance. Bei einem System mit 90+ Modulen und großen Medienbibliotheken sparen diese Tools Sekunden bei jeder Interaktion, was den "Mental Flow" des Operators erhält.

### Warum das dynamische MOTD?
Gemäß dem **"Aviation-Grade" Prinzip** (Audit v2.3) muss der Operator sofort über den Systemzustand informiert werden. Ein blindes Absetzen von Befehlen auf einem instabilen System wird so vermieden. Das Farbschema (Grün/Rot) ermöglicht eine Fehlererkennung in unter 1 Sekunde nach dem Login.

---
> [ARCHITECT-NOTE]: Veredelt aus mynixos/00-core/shell.nix und Audit-Prompt v2026.02.26
