---
title: Sovereign Identity (Passkey Standard)
category: architecture/identity
capabilities: [passkeys, oidc, zero-trust, passwordless]
sources: [https://github.com/pocket-id/pocket-id]
---

# 🔐 Sovereign Identity: Der Passkey Standard

In mynixos folgen wir dem Zero-Trust Prinzip. Identität wird nicht durch unsichere Passwörter, sondern durch kryptografische Passkeys (WebAuthn) nachgewiesen.

## 🚀 Warum PocketID?
- **Passwordless:** Keine Datenbank mit Passwörtern, die gestohlen werden kann.
- **OIDC Provider:** Standardisierte Anbindung für alle Dienste (Caddy mTLS, Web-Apps).
- **Self-Hosted:** Du behältst die volle Kontrolle über deine Identitätsdaten.

## 🧩 Architektur-Integration (Layer 40)
PocketID wird als zentraler Dienst in `modules/services/identity.nix` definiert (Arion-basiert).

## 🛡️ SRE-Hardening
- Der Zugriff auf das PocketID-Backend wird zusätzlich durch den **Cloudflare Tunnel** (mTLS) gesichert.
- Secrets für OIDC-Clients werden via `sops-nix` verwaltet.
