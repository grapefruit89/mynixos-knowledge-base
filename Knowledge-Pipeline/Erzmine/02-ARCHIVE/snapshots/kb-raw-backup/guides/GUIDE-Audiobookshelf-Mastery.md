---
title: 📚 Audiobookshelf Mastery (Layer 40-media)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [audiobook-streaming, podcast-management, oidc-identity, mobile-sync]
sources: [https://github.com/advplyr/audiobookshelf, official nixpkgs modules]
---

# 📚 Audiobookshelf: Deine private Bibliothek

In mynixos ist Audiobookshelf der Standard für Hörbücher und Podcasts. Wir nutzen die native NixOS-Integration für maximale Stabilität.

## 🏛️ Architektur-Entscheidungen (Efficiency Standard)
1.  **Datenbank:** Nutzt eine interne Datenbank (SQLite-basiert für Metadaten). ✅
2.  **Transcoding:** Greift auf systemweite ffmpeg-Binaries zu.
3.  **Identity:** Volle **PocketID** Integration via OIDC.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/40-media/audiobookshelf.nix\`):

\`\`\`nix
services.audiobookshelf = {
  enable = true;
  port = 8000;
  # host = \"127.0.0.1\"; # Nur Lokal + Caddy
};

# Wir injizieren die Secrets via systemd
systemd.services.audiobookshelf.serviceConfig = {
  EnvironmentFile = config.sops.secrets.\"abs/env\".path;
};
\`\`\`

## 🛡️ SRE-Hardening
- **Ingress:** Sicherung via Caddy über \`books.m7c5.de\` mit mTLS.
- **Backups:** Nutzung von \`BACKUP_PATH\`, der direkt vom Restic-Dienst (Layer 80) erfasst wird.
