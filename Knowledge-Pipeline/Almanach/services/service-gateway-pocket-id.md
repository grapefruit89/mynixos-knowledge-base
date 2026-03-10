---
title: "Service: Pocket-ID Identity Provider (Aviation-Grade)"
category: "services"
tags: [security, oidc, sso, identity, dendritic]
id: "NIXH-10-GTW-009"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/10-gateway/pocket-id.nix"]
---

# Service: Pocket-ID (SSO Identity Provider)

## 1. User Layer (KISS)
Pocket-ID ist dein digitaler Schlüsselbund. Anstatt dir für jedes Programm (Jellyfin, Paperless, etc.) ein eigenes Passwort zu merken, meldest du dich einmal zentral bei Pocket-ID an – am besten ganz ohne Passwort mit einem Passkey (Fingerabdruck oder Gesichtsscan). Einmal angemeldet, lässt dich der Server automatisch in alle deine Dienste rein.

## 2. Technical Layer (Aviation-Grade)

### Architektur & OIDC-Rolle
Das Modul implementiert einen souveränen **OpenID Connect (OIDC)** Provider:
*   **Issuer:**  (basierend auf SSoT-Domain).
*   **Integration:** Dient als Auth-Backend für den Caddy  Snippet.
*   **Datenhaltung:** Alle Identitätsdaten liegen lokal unter .

### SRE-Hardening & Validierung
*   **Proxy-Pflicht:** Eine Nix-Assertion stellt sicher, dass Pocket-ID niemals ohne den Caddy-Proxy aktiviert wird.
*   **Systemd Isolation:** Nutzt  und .
*   **Warn-System:** Generiert eine System-Warnung, solange die öffentliche Registrierung () aktiv ist.

### Integration (Nix-Snippet)


## 3. Reasoning Layer (History)

### [ADR-041] Pocket-ID vs. Keycloak/Authelia
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Keycloak ist zu schwergewichtig für den i3-9100, Authelia erfordert komplexe YAML-Konfigurationen.
*   **Entscheidung:** Nutzung von Pocket-ID.
*   **Vorteile:** Minimalistischer Footprint (~20MB RAM), native Passkey-Unterstützung (WebAuthn), extrem einfache Integration in Caddy via Forward-Auth.

### [ADR-042] Opt-out for Vaultwarden
*   **Begründung:** Der Passwortmanager (Vaultwarden) wird bewusst **nicht** an Pocket-ID angebunden, um eine zirkuläre Abhängigkeit zu vermeiden (man braucht die Passwörter, um sich am SSO anzumelden).
