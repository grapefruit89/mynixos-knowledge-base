---
title: 🔍 FINDINGS-REGISTRY (The SRE Paper Trail)
category: architecture/traceability
status: [ACTIVE-LOG]
description: Physischer Nachweis aller dekonstruierten Quellen und extrahierten Nuggets.
---

# 🔍 Fundstellen-Datenbank: Der SRE Paper-Trail

Dieses Dokument listet alle externen Quellen auf, die für die Architektur von mynixos dekonstruiert wurden.

## 📅 Session: 2026-03-09 (The Mining Marathon)

### 🏗️ Infrastruktur & Core
- [**Caddy Official Docs**](https://caddyserver.com/docs/)
    - **Nugget:** API-Control via Port 2019 und JSON-Config Adapter.
- [**Nixpkgs: initrd-ssh.nix**](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/initrd-ssh.nix)
    - **Nugget:** Remote LUKS Unlock für Headless-Server.
- [**Nixpkgs: nftables.nix**](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/nftables.nix)
    - **Nugget:** Build-time validation des Rulesets.

### 📊 Monitoring & Alerts
- [**TwiN/gatus**](https://github.com/TwiN/gatus)
    - **Nugget:** Native Matrix-Alerting Provider und YAML-first Config.
- [**r/Nix: njq Tool**](https://github.com/fadcreations/njq)
    - **Nugget:** JSON-Queries mit nativer Nix-Syntax.

### 🎬 Media & Storage
- [**advplyr/audiobookshelf**](https://github.com/advplyr/audiobookshelf)
    - **Nugget:** Native OIDC-Routen für PocketID Integration.
- [**jellyfin/jellyfin**](https://github.com/jellyfin/jellyfin)
    - **Nugget:** QuickSync Device-Mapping (/dev/dri/renderD128).
- [**deuxfleurs/garage**](https://github.com/deuxfleurs/garage)
    - **Nugget:** Rust-basierter S3-Speicher mit Metadaten/Daten-Trennung.

### 🛡️ Security & Policy
- [**numtide/srvos**](https://github.com/numtide/srvos)
    - **Nugget:** Standardisierte serviceConfig Hardening-Templates.
- [**r/Nix: Stable MAC Naming**](https://reddit.com/r/NixOS/comments/1rllpea/)
    - **Nugget:** systemd.link Bindung für persistente Interface-Namen.

## 🚀 SRE-Standard
Jede neue Quelle MUSS hier mit Datum und extrahiertem Nugget eingetragen werden, bevor sie in einen Guide überführt wird.
