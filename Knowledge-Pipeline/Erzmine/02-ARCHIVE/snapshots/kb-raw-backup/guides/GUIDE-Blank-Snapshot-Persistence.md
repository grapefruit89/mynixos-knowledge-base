---
title: 🧹 Blank Snapshot Persistence (The Peak of Purity)
category: architecture/hygiene
status: [ACTIVE-SSoT]
capabilities: [root-rollback, btrfs-management, opt-in-persistence]
sources: [https://github.com/Misterio77/nix-config]
---

# 🧹 Blank Snapshot Persistence: "Erase your darlings"

Basierend auf den Patterns von Misterio77 führen wir die System-Hygiene auf das nächste Level.

## 🏛️ Das Prinzip
Anstatt nur Dateien zu löschen, wird das gesamte Root-Dateisystem (\`/\`) bei jedem Bootvorgang physisch durch einen leeren BTRFS-Snapshot ersetzt.

## 🛠️ Technische Umsetzung (BTRFS Workflow)
1.  **Boot-Phase:** Ein initrd-Script löscht das aktuelle root-Subvolume.
2.  **Rollback:** Ein leerer Snapshot (benannt \`blank\`) wird als neues \`root\` eingehängt.
3.  **Opt-in:** Nur Verzeichnisse, die wir in Nix deklarieren, werden nach \`/persist\` gemountet.

## 🚀 Der SRE-Vorteil
- **Garantierte Reinheit:** Es ist physisch unmöglich, dass sich Schadsoftware oder Konfigurations-Leichen im System verstecken.
- **Reproduzierbarkeit:** Wenn es nach dem Boot läuft, steht es in der Nix-Config. Wenn nicht, existiert es nicht.

## 🧩 Modul-Integration
In mynixos nutzen wir dies in Verbindung mit dem \`90-policy\` Layer, um die Einhaltung der deklarativen Pflicht zu erzwingen.