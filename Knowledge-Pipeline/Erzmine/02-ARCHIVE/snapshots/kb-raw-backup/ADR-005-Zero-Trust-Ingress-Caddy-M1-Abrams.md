---
id: ADR-005
title: Zero-Trust Ingress with Caddy (M1 Abrams Edition)
status: accepted
date: 2026-03-10
tags: [caddy, networking, zero-trust, mtls, sso, pocketid, cloudflare]
---

# ADR-005: Zero-Trust Ingress with Caddy (M1 Abrams Edition)

## 1. USER LAYER (KISS)
Unser Web-Eingangstor (Ingress) ist wie ein moderner Kampfpanzer (M1 Abrams) gesichert. Wir nutzen **Caddy** als Reverse Proxy. Der Zugriff erfolgt entweder über **mTLS** (digitale Ausweise auf deinem Gerät, kein Passwort nötig) oder über ein zentrales **SSO (Single Sign-On)** via Pocket-ID. Das System erkennt automatisch, ob du im heimischen LAN/Tailnet bist (Trusted) oder von außen kommst (Authentication required).

## 2. TECHNICAL LAYER (Specification)

### Caddy Architektur (Aviation-Grade Hardening)
Der Caddy-Dienst ist über Systemd-Sandboxing maximal isoliert (`ProtectSystem=strict`, `MemoryDenyWriteExecute=true`).

#### mTLS Konfiguration:
```caddy
(mtls_auth) {
  tls {
    client_auth {
      mode require_and_verify
      trust_pool file /etc/nixos/secrets/mtls/ca.crt
    }
  }
}
```
*Vorteil:* Nur Geräte mit dem korrekten Zertifikat können überhaupt eine Verbindung aufbauen.

#### Pocket-ID SSO mit Forward-Auth:
```caddy
(sso_auth) {
  @needs_auth {
    not remote_ip 127.0.0.1 10.0.0.0/8 # ... Trusted IPs
  }
  forward_auth @needs_auth localhost:8080 {
    uri /api/auth/verify
    copy_headers X-Forwarded-User
  }
}
```
*Logik:* Wenn die IP nicht aus dem Trusted-Pool (LAN/Tailscale/Cloudflare) stammt, wird die Anfrage zur Verifizierung an Pocket-ID weitergeleitet.

### Kernel & Performance Tuning
Zur Optimierung hoher Lasten (z.B. Media-Streaming) werden Kernel-Parameter angepasst:
- `net.core.rmem_max = 8388608` (Größere Receive-Buffer)
- `net.ipv4.tcp_fastopen = 3` (Schnellerer TCP-Handshake)

## 3. REASONING LAYER (ADR)

### Warum Caddy statt Nginx oder Traefik?
- **Automatisches TLS:** Caddy verwaltet Zertifikate (auch Wildcards via Cloudflare DNS-01) nativ und fehlerfrei.
- **Konfiguration:** Die Caddyfile-Syntax ist wesentlich lesbarer und modularer (Snippets wie `(mtls_auth)`).

### Warum mTLS + SSO?
- **Defense in Depth:** mTLS schützt auf Protokoll-Ebene (Layer 4/7), während SSO die Benutzer-Identität (Layer 7) prüft. Selbst wenn ein Passwort gestohlen wird, scheitert der Angreifer am fehlenden mTLS-Zertifikat.

### Warum Cloudflare DNS-01 Challenge?
Dies ermöglicht SSL-Zertifikate für interne Dienste, ohne dass Port 80/443 nach außen geöffnet werden muss. Die Verifizierung erfolgt über DNS-Einträge.

---
> [ARCHITECT-NOTE]: Extrahiert aus mynixos/10-gateway/caddy.nix (v2026.03.03)
