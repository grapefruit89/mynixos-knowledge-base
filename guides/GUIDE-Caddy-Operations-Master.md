---
title: 🛡️ Caddy Operations Master-Config (Layer 20-server)
category: architecture/ingress
status: [ACTIVE-SSoT]
capabilities: [ingress-automation, zero-downtime, api-control, caddyfile-mastery]
sources: [https://caddyserver.com/docs/]
---

# 🛡️ Caddy Operations: Der mynixos Standard

Caddy ist das Herzstück deines Ingress-Layers. Wir nutzen die offizielle Philosophie für maximale Zuverlässigkeit.

## 🛠️ Der SRE-Workflow (CLI)
Wir nutzen diese Befehle zur Wartung:
1.  **Validierung:** \`caddy validate --config /etc/caddy/Caddyfile\` (Prüft Syntaxfehler).
2.  **Formatierung:** \`caddy fmt --overwrite /etc/caddy/Caddyfile\` (Garantierte Purity).
3.  **Trust:** \`caddy trust\` (Ermöglicht vertrauenswürdige interne HTTPS-Verbindungen).

## 📡 API-Interaktion
Für Live-Status-Abfragen nutzen wir den internen API-Endpunkt:
- **Status:** \`curl localhost:2019/config/\`
- **Reload:** \`curl -X POST \"http://localhost:2019/load\" -H \"Content-Type: application/json\" -d @config.json\`

## 🧩 Caddyfile Architektur (Dendritic Style)
Wir nutzen **Snippets**, um Redundanz zu vermeiden:
\`\`\`caddy
(pocket_id_auth) {
    forward_auth localhost:8080 {
        uri /api/oidc/auth
    }
}

# Anwendung im Dendriten
jellyfin.m7c5.de {
    import pocket_id_auth
    reverse_proxy localhost:8096
}
\`\`\`

## 🛡️ SRE-Hardening
- **Zero-Downtime:** Der \`reload\` Mechanismus von Caddy ist der Standard für alle mynixos-Updates.
- **Auto-HTTPS:** Wir verlassen uns auf die CertMagic-Engine (Kapitel 8).
