---
title: 🛡️ AdGuardHome DNS Shield (Layer 20-server)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [ad-blocking, dns-over-tls, dhcp-server, network-security]
sources: [https://github.com/AdguardTeam/AdGuardHome, official nixpkgs modules]
---

# 🛡️ AdGuardHome: Dein DNS-Schutzschild

In mynixos ist AdGuardHome der zentrale DNS-Resolver. Er schützt alle Geräte in deinem Netzwerk vor Werbung und Tracking.

## 🏛️ Architektur-Entscheidungen (SRE Standard)
1.  **Sprache:** Go (Binary-Mandat erfüllt). ✅
2.  **Deployment:** Läuft als nativer systemd-Dienst.
3.  **Persistence:** Alle Filterdaten liegen in \`/persist/var/lib/adguardhome\`.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/20-server/dns.nix\`):

\`\`\`nix
services.adguardhome = {
  enable = true;
  mutableSettings = true; # Erlaubt UI-Änderungen für Filter-Listen
  settings = {
    dns = {
      upstream_dns = [
        \"https://dns.cloudflare.com/dns-query\"
        \"https://dns.google/dns-query\"
      ];
    };
    filtering = {
      safe_search.enabled = true;
    };
  };
};
\`\`\`

## 🛡️ SRE-Hardening
- **Port-Isolation:** Der DNS-Dienst (Port 53) ist nur im LAN und Tailnet erreichbar.
- **Ingress:** Das Web-Dashboard wird via Caddy über \`dns.m7c5.de\` mit mTLS abgesichert.
