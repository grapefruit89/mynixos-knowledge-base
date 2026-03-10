---
title: "Identity Standard: Passkey-Only & Pocket-ID"
category: "adr"
tags: [security, identity, passkey, pocket-id]
date: 2026-03-08
source: "raw/docs/Gemini-Pocket ID_ Nur Passkey-Login einrichten.md"
status: "verified-substance"
---

# 🔐 [ADR-INFO]: PASSKEY-ONLY LOGIN STANDARD

## Status: Akzeptiert
## Entscheidung
Zur Eliminierung von Phishing-Risiken und Password-Bruteforce setzen wir auf **Passkey-Only Authentifizierung**. Pocket-ID fungiert als zentraler OIDC Provider für alle Services der Distribution.

### Technische Härtung
- `POCKET_ID_ALLOW_PASSWORD_LOGIN = "false"`
- `POCKET_ID_PUBLIC_REGISTRATION = "false"`

> [LIVE-ENRICHMENT]: Die Integration erfolgt über das Caddy-Snippet `sso_auth`, welches jeden Request gegen den Pocket-ID `/api/auth/verify` Endpunkt validiert.

## ⚠️ DISASTER RECOVERY
Da Passwort-Login deaktiviert ist, muss zwingend ein **Backup-YubiKey** als zweiter Passkey registriert werden. Im Notfall kann der Passwort-Login temporär über den Master-USB-Stick (Partition 2) via `EnvironmentFile` Override reaktiviert werden.
