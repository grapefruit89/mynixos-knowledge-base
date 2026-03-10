---
title: Caddy M1 Abrams (Ingress Standard)
category: architecture/services
capabilities: [reverse-proxy, acme-dns, mtls-ready, hard-security]
sources: [https://github.com/nix-community/nixpkgs, https://github.com/lucaslorentz/caddy-docker-proxy]
---

# 🛡️ Caddy M1 Abrams: Der Ingress-Standard

Caddy ist das Gesicht deines Systems nach außen. Wir nutzen die "M1 Abrams" Edition für maximale Sicherheit.

## 🚀 Key Features
- **ACME DNS-01:** Zertifikate via Cloudflare DNS Challenge (Keine offenen Ports 80/443 für ACME nötig).
- **mTLS Ready:** Vorbereitet für interne Client-Zertifikat-Validierung.
- **Sops Integration:** Das Cloudflare Token wird sicher via SRE Tor 4 bereitgestellt.

## 🧩 Modul-Integration
Der Caddy-Dendrit liegt in `modules/services/caddy.nix`.

## 🛡️ Hardening
- **ProtectSystem=strict**
- **PrivateTmp=true**
- **NoNewPrivileges=true**
