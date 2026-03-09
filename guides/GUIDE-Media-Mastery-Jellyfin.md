---
title: 🎬 Jellyfin Media Mastery (Layer 40-media)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [media-streaming, hardware-acceleration, api-control, oidc-identity]
sources: [https://github.com/jellyfin/jellyfin, official nixpkgs modules]
---

# 🎬 Jellyfin: Das Herz deines Medien-Stacks

In mynixos nutzen wir Jellyfin als primäres Streaming-Backend. Wir optimieren es für Hardware-Transcoding und nahtlose Identitäts-Anbindung.

## 🏛️ Architektur-Entscheidungen (Efficiency Standard)
1.  **Transcoding:** Wir nutzen Intel QuickSync (Kapitel 25).
2.  **Storage:** Trennung von Config (Tier A) und Medien (Tier C via MergerFS).
3.  **Identity:** Anbindung an **PocketID** via OIDC-Plugin.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/40-media/jellyfin.nix\`):

\`\`\`nix
services.jellyfin = {
  enable = true;
  # Pfade kommen in den Impermanence-Layer
};

# Wir injizieren die GPU-Flags
systemd.services.jellyfin.serviceConfig = {
  DeviceAllow = [ \"/dev/dri/renderD128\" ];
};
\`\`\`

## 🛡️ SRE-Hardening
- **Ingress:** Sicherung via Caddy über \`jelly.m7c5.de\` mit mTLS.
- **Monitoring:** Integration des Webhook-Plugins, um Wiedergabe-Events an Matrix (Kapitel 20) zu senden.
