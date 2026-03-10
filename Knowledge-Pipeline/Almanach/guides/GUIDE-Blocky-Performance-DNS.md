---
title: ⚡ Blocky Performance DNS (Layer 20-server)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [ultra-fast-dns, doh-dot-support, prometheus-metrics, declarative-filter]
sources: [https://github.com/0xERR0R/blocky, official nixpkgs modules]
---

# ⚡ Blocky: Der hocheffiziente DNS-Proxy

In mynixos ist Blocky die performante Alternative zu AdGuardHome. Er ist ideal für SREs, die maximale Geschwindigkeit und minimale Ressourcenbindung suchen.

## 🏛️ Architektur-Entscheidungen (Efficiency Standard)
1.  **Sprache:** Go (Binary-Mandat erfüllt). ✅
2.  **Stateless:** Keine Datenbank nötig. Alle Statistiken werden via Prometheus exportiert.
3.  **Config-First:** Keine Web-UI. Die gesamte Steuerung erfolgt über die Nix-Datei.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/20-server/dns-performance.nix\`):

\`\`\`nix
services.blocky = {
  enable = true;
  settings = {
    ports.dns = 53;
    upstream = {
      default = [
        \"https://one.one.one.one/dns-query\"
        \"8.8.8.8\"
      ];
    };
    blocking = {
      blackLists = {
        ads = [ \"https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts\" ];
      };
      clientGroupsBlock = {
        default = [ \"ads\" ];
      };
    };
    prometheus = {
      enable = true;
      path = \"/metrics\";
    };
  };
};
\`\`\`

## 🛡️ SRE-Hardening
- **API-Sicherheit:** Die REST-Schnittstelle ist nur lokal (127.0.0.1) erreichbar.
- **DoH/DoT:** Wir erzwingen verschlüsseltes DNS zu den Upstream-Providern.
