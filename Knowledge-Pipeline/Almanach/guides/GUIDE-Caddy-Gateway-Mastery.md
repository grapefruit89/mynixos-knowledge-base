---
title: 🌐 Caddy Gateway Mastery (The Pro-Layer)
category: architecture/gateway
status: [ACTIVE-SSoT]
capabilities: [json-api-control, graceful-reloads, on-demand-tls, metrics-exporter]
sources: [Caddy Official Docs, Caddy GitHub, NixOS Module Audit]
---

# 🌐 Caddy: Das Gehirn deines Netzwerks

In mynixos verschmelzen wir die deklarative Power von Nix mit der dynamischen Agilität der Caddy-API.

## ⚡ 1. Zero-Downtime Updates (Graceful Reload)
Wir nutzen die nativen Caddy-Reload-Signale, um deine aktiven Streams (Jellyfin/Navidrome) bei Konfigurations-Updates zu schützen.
- **SRE-Vorteil:** Die Konfiguration wird atomar im Speicher getauscht. Kein Abbruch von HTTP-Sessions. ✅

## 💎 2. Die Admin-API (Monitoring & Control)
Caddy bietet eine mächtige REST-API auf Port 2019. Wir nutzen dies für Echtzeit-Einsichten.
- **Pattern:** Integration in Prometheus/Grafana für Layer 80 Monitoring.
- **SRE-Kontrolle:** Wir können Routen im Notfall über die API deaktivieren, ohne einen kompletten System-Rebuild abzuwarten.

## 🛡️ 3. On-Demand TLS (Dynamic SSL)
Caddy kann Zertifikate beim ersten Zugriff automatisch generieren.
- **Dienst:** \`on_demand_tls { ... }\` in den Global Options.
- **Vorteil:** Maximale Flexibilität für temporäre Test-Domains innerhalb deines m7c5.de Netzwerks. ✅

## 🏛️ 4. Native JSON-Injektion
Wo das Caddyfile an seine Grenzen stößt, injizieren wir direkt das hochperformante Caddy-JSON.
- **Anwendung:** Komplexe Filter für Layer 90-policy (z.B. Geo-Blocking oder mTLS-Verschachtelungen).