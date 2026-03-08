---
title: "Cloudflare Homeserver Setup & Zero Trust"
category: "services"
tags: [cloudflare, tunnel, zero-trust, security, traefik]
date: 2026-03-08
source: "raw/_duplikate/Claude-Homeserver mit Cloudflare sicher einrichten (1).md"
status: "verified-substance"
---

# 🛡️ SERVICE: CLOUDFLARE ZERO TRUST INTEGRATION

Dokumentation der Absicherung des Fujitsu Q958 Heimservers ohne offene Ports am Router.

> **Verwandte Konzepte:** 
> - [NixHome Architecture](../adr/nixhome-architecture.md)
> - [Isomorphie-Strategie](../adr/isomorphie-strategie.md)

## 🏗️ ARCHITEKTUR-ÜBERSICHT
Der Zugriff von außen erfolgt ausschließlich über verschlüsselte Cloudflare Tunnels (Argo).

### Komponenten-Matrix
- **Host-IP:** `192.168.2.250`
- **Reverse-Proxy:** Traefik (Port 80, 443, 8183)
- **Identity Provider:** Cloudflare Access (Google / GitHub / Apple Integration)

## 🛠️ TECHNISCHE UMSETZUNG (CLOUDFLARED)
```nix
services.cloudflared = {
  enable = true;
  tunnels = {
    "q958-main" = {
      credentialsFile = "/run/secrets/cloudflared-creds";
      ingress = {
        "vault.m7c5.de" = "http://localhost:4743";
        "jellyfin.m7c5.de" = "http://172.18.0.5:8096"; # Direktes Container-Routing
      };
      default = "http_status:404";
    };
  };
};
```

> [ARCHITECT-NOTE]: Vermeide "Redirect Loops" (HTTP -> HTTPS -> Tunnel -> Traefik -> Tunnel). Das Tunnel-Routing sollte idealerweise direkt auf die Container-IPs oder den lokalen App-Port zeigen, um Traefik-Overhead für externe Zugriffe zu minimieren.

> [LIVE-ENRICHMENT]: Aktuelle Sicherheits-Empfehlungen von Cloudflare (2026) raten zur Nutzung von **Service Tokens** für die API-Kommunikation zwischen n8n und anderen Diensten über den Tunnel, um die Interaktive Authentifizierung (Login-Maske) für automatisierte Workflows zu umgehen.

## 🧠 SRE CHECKLISTE
- [x] Tunnel-Authentifizierung via SOPS-Secrets.
- [x] DNS-Resolver in Cloudflare auf `proxied` gestellt.
- [x] WAF-Regeln für Geoblocking (Nur DE/EU erlauben).

---

## 📈 VIII. KUMULATIVE VEREDELUNG (BATCH 2)

> [SEARCH-ENRICHMENT]: Das Setup von **Cloudflare Access** als Gatekeeper vor **Pocket-ID** erlaubt eine zentrale Autorisierung. In der CF Zero Trust Console wird Pocket-ID als "Generic OIDC Provider" registriert. Dies ermöglicht Single-Sign-On (SSO) für alle proxied Dienste.

> [ARCHITECT-NOTE]: Die Trennung in **Orange Cloud** (Apps) und **Gray Cloud** (Media) ist essenziell. 
> - **Gray Cloud (DNS-only):** Für `jellyfin.m7c5.de`. Erfordert in Traefik eine `ipAllowList` Middleware oder die Nutzung von Tailscale, da die IP-Adresse physisch exponiert ist.
> - **Orange Cloud (Proxied):** Für `vault.m7c5.de`. Nutzt Cloudflare WAF und CDN-Caching.

> [TECHNICAL-DETAIL]: Das Onboarding der Familie erfolgt via **Passkeys**. Pocket-ID generiert einmalige Invite-Links. Nach der Registrierung (FaceID/TouchID) ist der Zugang für alle OIDC-fähigen Dienste (Jellyfin, ABS, Seerr) ohne Passwort-Eingabe aktiv.
