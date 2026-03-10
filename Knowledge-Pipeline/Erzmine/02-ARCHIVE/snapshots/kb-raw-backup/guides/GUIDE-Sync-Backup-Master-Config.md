---
title: 🔄 Sync & Backup Master-Config (Layer 80-monitoring)
category: architecture/storage
status: [ACTIVE-SSoT]
capabilities: [p2p-sync, encrypted-backups, rclone-integration, offsite-redundancy]
sources: [NixOS Manual, official nixpkgs modules, Syncthing Docs]
---

# 🔄 Sync & Backup: Deine Daten-Versicherung

In mynixos folgen wir dem 3-2-1 Backup-Prinzip. Wir nutzen hocheffiziente Werkzeuge für den Sync und die Sicherung.

## 📡 1. Syncthing: Die P2P-Cloud (Layer 50)
Wir nutzen Syncthing für den Echtzeit-Sync von Dokumenten und Fotos.
- **Deklarativ:** Alle Geräte und Ordner werden in der Nix-Config definiert (\`services.syncthing.settings\`).
- **Isolation:** Syncthing läuft als dedizierter User und ist via Caddy abgesichert.

## 🛡️ 2. Restic: Das Aviation-Grade Backup (Layer 80)
Restic ist unser Standard für verschlüsselte, deduplizierte Backups.
- **Technik:** Nutzt Rclone als Backend für Cloud-Storage (S3, B2, Drive).
- **Automation:** Tägliche systemd-Timer triggern den Backup-Run und den anschließenden \`restic check\`.
- **Nix-Config:** \`services.restic.backups.main = { ... };\`

## 🚀 SRE-Anwendung
Backups sind nur wertvoll, wenn sie validiert sind. Wir integrieren \`matrix-hook\` (Kapitel 20), um den Status jedes Backup-Runs sofort zu melden.
