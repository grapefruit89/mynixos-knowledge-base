---
title: 🛡️ Caddy M1 Abrams (Ingress Standard)
category: architecture/guides
status: [ACTIVE-SSoT]
sources: [adr/nixhome-architecture.md, modules/services/caddy.nix]
---

# 🛡️ Caddy M1 Abrams: Der Ingress-Standard

Wir nutzen Caddy als gehärteten Reverse-Proxy. Im Gegensatz zu Legacy-Ansätzen (Traefik) setzen wir auf native NixOS-Integration und Sops-Secrets.

## Kern-Konfiguration
- **DNS-01 Challenge:** Automatisierte Zertifikate via Cloudflare.
- **Forward-Auth:** Anbindung an PocketID (OIDC).
- **Hardening:** Strikte Systemd-Isolation.

Siehe: [adr/nixhome-architecture.md](../adr/nixhome-architecture.md)
