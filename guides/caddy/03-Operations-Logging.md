---
title: 📊 Caddy Operations & Structured Logging
category: architecture/ingress
status: [ACTIVE-SSoT]
capabilities: [structured-logging, zap-performance, systemd-hardening]
sources: [https://caddyserver.com/docs/logging, https://caddyserver.com/docs/running]
---

# 📊 Caddy Operations: Wartung & Monitoring

## 1. Strukturiertes Logging
Caddy nutzt das **Zap-Framework** für JSON-Logs.
- **Vorteil:** Maschinenlesbar, perfekt für Grafana Loki oder ELK.
- **Konfiguration:** Sinks und Filter werden global oder pro Site definiert.

## 2. Systemd Integration (NixOS Standard)
- **Service:** \`caddy.service\`
- **Reload:** \`systemctl reload caddy\` (SIGUSR1). Verhindert Verbindungsabbrüche.
- **Secrets:** Einbindung via \`EnvironmentFile\` (Sops-Nix Integration).

## 3. Validierung & Purity
- **Befehl:** \`caddy validate --config /etc/caddy/Caddyfile\`
- **Befehl:** \`caddy fmt --overwrite\` (Erzwingt mynixos Coding-Standards).