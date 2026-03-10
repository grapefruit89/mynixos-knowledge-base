---
title: 💎 Advanced Hidden Gems Master-Config (Layer 50/80)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [private-search, binary-caching, pro-downloading]
sources: [NixOS Search, Attic Docs, SearXNG Documentation]
---

# 💎 Advanced Hidden Gems: Die Profi-Tools

In mynixos nutzen wir spezialisierte Dienste für maximale Effizienz und Privatsphäre.

## 🏛️ SearXNG: Die private Suche (Layer 50)
Wir nutzen SearXNG als Standard-Metasuchmaschine.
\`\`\`nix
services.searx = {
  enable = true;
  settings = {
    server.secret_key = "@SEARX_KEY@"; # Sops injection
    engines = [ { name = "google"; engine = "google"; } ];
  };
};
\`\`\`

## ⚙️ Attic: Der Binär-Cache (Layer 80)
Attic erlaubt es uns, Build-Artefakte zwischen Tower und Clients zu teilen.
\`\`\`nix
services.atticd = {
  enable = true;
  settings = {
    database.url = "postgres:///atticd";
    storage.type = "s3"; # Oder local
  };
};
\`\`\`

## 📥 Aria2: Pro-Downloader (Layer 20)
Ein hocheffizienter Daemon für alle Download-Arten.
\`\`\`nix
services.aria2 = {
  enable = true;
  settings = {
    rpc-listen-port = 6800;
    rpc-secret = "@ARIA_KEY@";
  };
};
\`\`\`

## 🛡️ SRE-Hardening
Alle diese Dienste werden via Caddy (Layer 20) über das Tailnet oder mTLS abgesichert. Secrets für die RPC-Keys werden via Sops-Nix injiziert.