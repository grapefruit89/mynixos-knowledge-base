---
title: 🎵 Navidrome Audio Mastery (Layer 40-media)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [music-streaming, go-performance, subsonic-api, lightweight-audio]
sources: [https://www.navidrome.org/, official nixpkgs modules]
---

# 🎵 Navidrome: Deine private Musik-Cloud

In mynixos nutzen wir Navidrome als hochperformanten Musik-Server. Er schlägt Jellyfin im Bereich Audio durch minimalen Ressourcenverbrauch.

## 🏛️ Architektur-Entscheidungen (Efficiency Standard)
1.  **Sprache:** Go (Binary-Mandat erfüllt). ✅
2.  **Datenbank:** SQLite (Eingebettet). ✅
3.  **Transcoding:** On-the-fly Umwandlung via ffmpeg (QuickSync ready).

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/40-media/navidrome.nix\`):

\`\`\`nix
services.navidrome = {
  enable = true;
  settings = {
    Address = \"127.0.0.1\";
    Port = 4533;
    MusicFolder = \"/mnt/storage/media/music\";
    DataFolder = \"/persist/var/lib/navidrome\";
    LogLevel = \"info\";
    ScanSchedule = \"@every 1h\";
  };
};
\`\`\`

## 🛡️ SRE-Hardening
- **Ingress:** Sicherung via Caddy über \`music.m7c5.de\`.
- **Identity:** Navidrome unterstützt zwar kein direktes OIDC, wir sichern den Zugang jedoch via Tailscale-Auth oder Caddy-Forward-Auth.
