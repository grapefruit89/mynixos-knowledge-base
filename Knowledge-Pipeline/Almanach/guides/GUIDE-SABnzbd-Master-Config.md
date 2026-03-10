---
title: 📥 SABnzbd Master-Config (Layer 40-media)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [usenet-downloader, secrets-integration, declarative-config]
sources: [https://github.com/sabnzbd/sabnzbd, official nixpkgs modules]
---

# 📥 SABnzbd: Der hocheffiziente Usenet-Motor

In mynixos nutzen wir SABnzbd als primären Downloader für den ARR-Stack.

## 🏛️ Architektur-Entscheidungen (SRE Standard)
1.  **Total Control:** Wir setzen \`allowConfigWrite = false\`. Einstellungen im Web-UI werden beim Neustart durch den Nix-Code überschrieben.
2.  **Sops-Secrets:** Server-Passwörter und API-Keys kommen aus \`secrets/secrets.yaml\`.
3.  **Efficiency:** Wir begrenzen den RAM-Cache via \`settings.misc.cache_limit\`.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/40-media/sabnzbd.nix\`):

\`\`\`nix
services.sabnzbd = {
  enable = true;
  user = "sabnzbd";
  group = "media"; # Zugriff auf Medien-Shares
  secretFiles = [ config.sops.secrets."sabnzbd/config".path ];
  settings = {
    misc = {
      host = "127.0.0.1";
      port = 8080;
      cache_limit = "256M";
    };
  };
};
\`\`\`

## 🛡️ SRE-Hardening
- **Ingress:** Sicherung via Caddy über \`sab.m7c5.de\` mit mTLS.
- **VPN:** SABnzbd wird zwingend in den VPN-Namespace (Kapitel 19) gezwungen.