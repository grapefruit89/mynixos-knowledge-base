---
title: 📚 Readeck: Knowledge Mastery (Layer 50-knowledge)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [bookmark-management, read-later, full-text-archiving, go-performance]
sources: [https://readeck.org/, NixOS Search]
---

# 📚 Readeck: Dein externes Gehirn

In mynixos nutzen wir Readeck als zentralen Dienst für Bookmarks und das Archivieren von Web-Inhalten.

## 🏛️ Architektur-Entscheidungen (Efficiency Standard)
1.  **Wahl:** Readeck gewinnt gegen Linkding durch native Nixpkgs-Integration und Go-Binary Performance.
2.  **Datenbank:** Nutzt SQLite (Standard). ✅
3.  **Self-Contained:** Keine externen Abhängigkeiten wie Redis nötig.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/50-knowledge/readeck.nix\`):

\`\`\`nix
# Readeck hat momentan kein fertiges Services-Modul, wir bauen es als systemd-unit
systemd.services.readeck = {
  description = "Readeck Web Archiver";
  after = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.readeck}/bin/readeck serve";
    User = "readeck";
    Group = "readeck";
    StateDirectory = "readeck";
    Environment = [ "READECK_LOG_LEVEL=info" ];
  };
};
\`\`\`

## 🛡️ SRE-Hardening
- **Ingress:** Sicherung via Caddy über \`read.m7c5.de\`.
- **Storage:** Persistierung des SQLite-Files in \`/persist/var/lib/readeck\`.