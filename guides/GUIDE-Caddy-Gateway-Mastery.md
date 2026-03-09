---
title: 🌐 Caddy Gateway Mastery (Layer 10-gateway)
category: architecture/gateway
status: [ACTIVE-SSoT]
capabilities: [declarative-plugins, dns-01-challenges, reverse-proxy-mastery, unix-sockets]
sources: [nixpkgs/nixos/modules/services/web-servers/caddy, rl-2505]
---

# 🌐 Caddy: Das intelligente Gateway

In mynixos ist Caddy nicht nur ein Webserver, sondern der zentrale intelligente Proxy, der Identität (Pocket-ID), Sicherheit (Fail2ban) und Erreichbarkeit steuert.

## 🏛️ 1. Die Plugin-Fabrik (Aviation-Grade Build)
Wir bauen Caddy direkt im Flake mit den nötigen Modulen für deine Infrastruktur.
\`\`\`nix
services.caddy.package = pkgs.caddy.withPlugins {
  plugins = [
    "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e" # DNS-01 SSL
    "github.com/mholt/caddy-webdav@v0.0.0-20241008162340-42168ba04c9d"   # WebDAV für Cloud
  ];
};
\`\`\`

## 🛡️ 2. Das "Master-Gateway" Prinzip
Apps mit internen Proxies (wie Pocket-ID oder Lemmy) werden "kastriert", damit unser Master-Caddy die volle Kontrolle behält.
- **Regel:** \`CADDY_DISABLED = "true"\` in den App-Umgebungen setzen.

## 🔑 3. DNS-01 Challenges (SSL-Perfektion)
Dank des Cloudflare-Plugins brauchen wir keine offenen Ports (80/443) für SSL-Zertifikate.
- **Vorteil:** Zertifikate für interne Domains (\`*.m7c5.de\`) werden sicher via DNS validiert.

## ⚡ 4. Unix-Socket Performance
Wo immer möglich, kommuniziert Caddy via Unix-Sockets mit den Backends (z.B. PHP-FPM, Gunicorn).
- **Vorteil:** Höhere Geschwindigkeit und keine Port-Kollisionen auf localhost.