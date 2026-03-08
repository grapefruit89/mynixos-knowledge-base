---
title: "Service: Caddy Gateway (M1 Abrams Edition)"
category: "services"
tags: [gateway, proxy, security, mtls, sso, cloudflare]
id: "NIXH-10-GTW-002"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/10-gateway/caddy.nix"]
---

# Service: Caddy Gateway (M1 Abrams Edition)

## 1. User Layer (KISS)
Caddy ist der "Türsteher" deines Servers. Er empfängt alle Anfragen aus dem Internet und leitet sie sicher an die richtigen Programme (wie Jellyfin oder Home Assistant) weiter. Die "M1 Abrams Edition" steht für maximale Panzerung: Er nutzt modernste Verschlüsselung (mTLS), verlangt bei Bedarf einen Ausweis (SSO) und optimiert sogar den "Motor" (Kernel) deines Servers für maximale Geschwindigkeit.

## 2. Technical Layer (Aviation-Grade)

### Ingress & SSL Strategie
*   **Wildcard TLS:** Nutzung der Cloudflare DNS-01 Challenge für `*.nix.m7c5.de`. Dies ermöglicht gültige HTTPS-Zertifikate für interne Dienste, ohne Ports nach außen öffnen zu müssen.
*   **Trusted Proxies:** Automatische Erkennung und Vertrauen von Cloudflare-IPs und dem internen Tailscale-Netzwerk.

### Sicherheits-Panzerung (M1 Abrams Snippets)
Das Modul definiert wiederverwendbare Sicherheits-Bausteine:
1.  **mtls_auth:** Erzwingt Mutual TLS (Client-Zertifikat). Zugriff wird nur gewährt, wenn der Browser ein von deiner privaten CA signiertes Zertifikat vorlegt.
2.  **sso_auth:** Integriert Pocket-ID via Forward-Auth. Externe Zugriffe müssen sich erst am Identity-Provider legitimieren.
3.  **Security Headers:** Erzwingt HSTS, No-Sniff und Frame-Deny zum Schutz vor Web-Angriffen.

### SRE-Performance & Hardening
*   **Kernel Tuning:** Optimierung von `net.core.rmem_max` und `tcp_fastopen` beim Start.
*   **Systemd Isolation:** `MemoryDenyWriteExecute = true` und `OOMScoreAdjust = -500` (Caddy stirbt als Letzter bei RAM-Not).
*   **Resource Protection:** `ProtectSystem = "strict"` und `ProtectHome = true` verhindern den Zugriff auf das restliche System.

## 3. Reasoning Layer (History)

### [ADR-034] Caddy vs. Traefik (The M1 Abrams Decision)
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Traefik bietet gute Docker-Integration, ist aber in einer rein binären NixOS-Umgebung komplexer zu konfigurieren (YAML-Overhead).
*   **Entscheidung:** Wechsel auf Caddy.
*   **Begründung:** Die Caddyfile-Syntax ist deutlich besser lesbar und die Integration von DNS-Challenges sowie mTLS ist mit weniger Code-Zeilen möglich. Die automatische Kernel-Optimierung ist ein Alleinstellungsmerkmal für performante Gateways.

### [ADR-035] mTLS for Administrative Access
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Passwörter für Admin-Tools (wie OliveTin oder Cockpit) können gestohlen werden.
*   **Entscheidung:** Zwingende Nutzung von mTLS für alle Schicht-00 und Schicht-10 Management-UIs.
*   **Vorteil:** Ein Angreifer müsste physischen Zugang auf ein registriertes Endgerät haben, um überhaupt den Login-Screen zu sehen.

---
**Community-Abgleich:** Konform zu `nixpkgs/nixos/modules/services/web-servers/caddy.nix` unter Nutzung von Cloudflare-Plugins.
