---
title: 🛡️ Caddyfile Mastery (Syntax & Directives)
category: architecture/ingress
status: [ACTIVE-SSoT]
capabilities: [reverse-proxy, routing-logic, caddyfile-syntax]
sources: [https://caddyserver.com/docs/caddyfile]
---

# 🛡️ Caddyfile Mastery: Die Konfigurations-Bibel

## 1. Grundstruktur
Ein Caddyfile besteht aus Site-Blöcken.
\`\`\`caddy
{
    # Global Options
    email moritzbaumeister@gmail.com
}

(snippet_name) {
    # Wiederverwendbare Logik
}

site.domain.de {
    import snippet_name
    reverse_proxy localhost:8080
}
\`\`\`

## 2. Kern-Direktiven
- **reverse_proxy:** Leitet Traffic an Backends weiter. Unterstützt Health-Checks und Load-Balancing.
- **handle:** Exklusive Logik-Blöcke (der erste Treffer gewinnt).
- **route:** Erwingt die exakte Reihenfolge der Ausführung.
- **header:** Manipuliert HTTP-Header (Sicherheit!).

## 3. Request Matcher
Erlauben präzises Routing basierend auf:
- \`@name { host domain.de path /api/* }\`
- \`not path /private/*\`
- \`header User-Agent *Mozilla*\`