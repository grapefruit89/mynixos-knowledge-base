---
title: 🎬 Media-Stack Hardening (VPN & Transcoding)
category: architecture/media
status: [ACTIVE-SSoT]
capabilities: [vpn-confinement, hardware-acceleration, media-purity]
sources: [https://github.com/nix-media-server/nixarr, https://github.com/kiriwalawren/nixflix]
---

# 🎬 Media-Stack: Aviation-Grade Entertainment

In mynixos wird der Medien-Stack (Layer 40) nicht einfach nur "ausgeführt", sondern gehärtet und optimiert.

## 🛡️ VPN-Confinement (The Nixarr Pattern)
Kritische Dienste (SABnzbd, Prowlarr) werden physisch auf einen VPN-Namespace beschränkt.
- **Ziel:** Kein Paket verlässt den Tower am VPN vorbei (Killswitch nativ in Nix).
- **Vorteil:** Keine "Lecks" der IP-Adresse.

## ⚡ Hardware-Transcoding (Intel QuickSync)
Dein Fujitsu Q958 nutzt die Intel UHD 630 GPU.
- **Treiber:** Wir nutzen konsequent den `intel-media-driver` (iHD).
- **Konfiguration:** `nixpkgs.config.packageOverrides = pkgs: { vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; }; };` (oder neuer Standard).

## 🧩 Modul-Integration
Jeder ARR-Dienst wird als Dendrit in `modules/40-media/` angelegt und injiziert seine eigenen Caddy-Ressourcen.