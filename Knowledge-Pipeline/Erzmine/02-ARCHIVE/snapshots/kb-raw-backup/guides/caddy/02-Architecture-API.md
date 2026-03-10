---
title: 🤖 Caddy Architecture & JSON API
category: architecture/ingress
status: [ACTIVE-SSoT]
capabilities: [programmable-proxy, modular-architecture, config-adapters]
sources: [https://caddyserver.com/docs/architecture, https://caddyserver.com/docs/api]
---

# 🤖 Caddy Architecture: Server of Servers

## 1. Das Modul-Modell
Caddy ist ein Konfigurations-Manager. Alles (TLS, HTTP, PKI) ist ein Modul mit eigenem Lebenszyklus (Load, Provision, Use, Cleanup).

## 2. JSON API (Native Control)
Caddy konfiguriert sich intern via JSON. Die API hört standardmäßig auf \`localhost:2019\`.
- **Config abfragen:** \`curl localhost:2019/config/\`
- **Zero-Downtime Push:** Neue Configs können via POST direkt in den Speicher geladen werden.

## 3. Config Adapters
Das Caddyfile wird durch einen "Adapter" in JSON übersetzt. Dies garantiert, dass die menschliche Lesbarkeit nicht auf Kosten der Mächtigkeit geht.