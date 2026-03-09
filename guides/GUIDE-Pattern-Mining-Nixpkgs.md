---
title: 🚜 Pattern Mining: Offizielle Nixpkgs Module
category: architecture/learning
status: [ACTIVE-SSoT]
capabilities: [systemd-hardening, module-structure, official-standards]
sources: [/home/Knowledge-Pipeline/raw/sources/nixpkgs-modules/]
---

# 🚜 Pattern Mining: Die Weisheit der Core-Maintainer

Wir nutzen die offiziellen NixOS-Module (\`nixpkgs/nixos/modules\`) als unsere primäre Quelle für Aviation-Grade Konfigurationen.

## 🏛️ Warum wir das tun?
Jedes Modul in nixpkgs wurde von der Community gereviewt. Es enthält:
- **Best-Practice systemd-Einheiten:** (z.B. \`DynamicUser\`, \`ProtectSystem\`).
- **Validierte Optionen:** (Typ-Prüfung für jede Einstellung).
- **Integrierte Tests:** (Wir sehen, wie die Maintainer den Dienst testen).

## 📂 Lokales Archiv
Du findest die Rohdateien deiner Dienste unter:
\`/home/Knowledge-Pipeline/raw/sources/nixpkgs-modules/\`

Nutze diese Dateien als Vorlage, wenn du einen neuen Dendriten in \`mynixos\` erstellst.

## 📂 Dein komplettes Anschauungsmaterial (Source-Modules)
Hier sind die offiziellen Vorlagen für deinen Tower:
- **Core:** sshd, nftables, fail2ban, sops
- **Ingress:** caddy, adguardhome, tailscale
- **Media-Stack:** sonarr, radarr, lidarr, prowlarr, jellyfin
- **Storage & Backup:** mergerfs, snapraid, restic, postgresql
- **Knowledge & Identity:** paperless, vaultwarden, conduit, home-assistant

## 💎 Hidden Gems (Erweiterte Suche)
Wir haben weitere hochkarätige Blaupausen identifiziert:
- **Search:** searx (SearXNG Standard)
- **Media:** readarr (Books), servarr-logic (Core Architecture)
- **Ops:** atticd (Binary Cache), aria2 (Pro-Downloader)
