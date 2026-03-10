---
title: "NixHome Isomorphie-Strategie"
category: "adr"
tags: [nixos, architecture, isomorphism, ssot]
date: 2026-03-08
source: "raw/_duplikate/NIXHOME_ISOMORPHIE_STRATEGIE.md"
status: "verified-substance"
---

# 🛰️ [ADR-INFO]: ISOMORPHIE-STRATEGIE — CODE ↔ DOCS ↔ OBSIDIAN (v4.2 Update)

Diese Strategie definiert die Single Source of Truth (SSoT) für das gesamte Homelab-Ökosystem. Ziel ist die perfekte strukturelle Spiegelung zwischen Nix-Code, Markdown-Dokumentation und dem Obsidian Knowledge-Graph.

## 🎯 DAS KERNPROBLEM: DIVERGIERENDE WAHRHEITEN & FRAGILES TOOLING
Bisher drifteten drei Welten auseinander:
1. `/etc/nixos/` (Nix-Code) – Was das System **tut**.
2. `650 Chaos-Docs/` (Markdown) – Was du **weißt**.
3. `Obsidian Vault/` (Knowledge DB) – Was du **findest**.

Das bisherige Tooling (`chunker.py`) basierte auf Regex-Parsing von Nix-Code, was bei komplexen Strukturen (Multiline-Strings, Bash-Snippets) zu Fehlern und "Phantom-IDs" führte.

## 🛠️ LÖSUNG: TRUE ISOMORPHY VIA NIX-EVAL (v4.2)
Die SSoT wird direkt in die Nix-Konfiguration integriert. Wir nutzen die Nix-Evaluierung selbst als Parser.

### 1. Meta-Schema Standardisierung (`lib-meta-schema.nix`)
Jedes Modul registriert sich über ein festes Schema in `options.my.meta`.
```nix
mkModuleMeta = {
  id = "NIXH-40-MED-007";
  title = "Jellyfin Media Server";
  layer = 40;
  status = "active";
  upstream = [ "NIXH-00-COR-HAL-001" ]; # Abhängigkeit von HAL (GPU)
};
```

### 2. Metadaten-Extraktion (`generate-index.sh`)
Statt Python-Regex nutzen wir `nix eval`, um ein sauberes JSON aller Modul-Metadaten zu generieren:
```bash
nix eval .#nixosConfigurations.nixhome.config.my.meta --json
```

### 3. Automatisierter Obsidian-Export
Aus dem evaluierten JSON werden automatisch:
- **`chunk_index.json`**: Der maschinenlesbare Index.
- **`dependency.dot`**: Der visualisierte Abhängigkeitsgraph.
- **Obsidian-Markdown**: Pro Modul eine Datei mit Backlinks (`[[NIXH/ID]]`).

## 🧠 REFAKTORIERUNGS-STRATEGIE (AUTOMATISIERT)
1. **Validierung:** Ein `pre-commit` Hook prüft bei jedem Git-Commit, ob die Metadaten valide sind und keine doppelten IDs existieren.
2. **Synchronisation:** Änderungen im Nix-Code führen automatisch zu Updates im Obsidian-Vault.
3. **Integrität:** Da Nix der Parser ist, gibt es keine Abweichungen mehr zwischen "Code" und "Dokumentation".

> [SOURCE-ENRICHMENT]: Aktualisiert am 8.3.2026 basierend auf dem SRE-Audit v4.2 (`Claude-03 Prompt-Übernahme anfragen.md`).
