---
title: Ingress Deep-Dive (Caddy + PocketID Integration)
category: architecture/ingress
capabilities: [forward-auth, oidc-integration, security-proxy, passkey-protection]
sources: [https://github.com/caddyserver/caddy, https://github.com/pocket-id/pocket-id]
---

# 🛡️ Ingress Deep-Dive: Caddy trifft PocketID

Um deine Dienste (Jellyfin, Home Assistant, etc.) abzusichern, nutzen wir Caddy als "Türsteher", der die Identität via PocketID prüft.

## 🚀 Das Forward-Auth Prinzip
Anstatt in jedem Dienst eine eigene Authentifizierung zu konfigurieren, übernimmt Caddy diese Aufgabe:
1.  **Anfrage:** Ein User ruft `jellyfin.dein-tower.ts` auf.
2.  **Check:** Caddy fragt via `forward_auth` beim PocketID-Dienst nach: "Darf dieser User das?"
3.  **Auth:** Wenn nicht eingeloggt, leitet PocketID zum Passkey-Login weiter.
4.  **Access:** Nach erfolgreichem Login leitet Caddy die Anfrage an den Jellyfin-Container weiter.

## 🧩 Modul-Konfiguration
In `modules/services/caddy.nix` nutzen wir die `forward_auth` Direktive:
```caddy
forward_auth identity:8080 {
    uri /outpost.goauthentik.io/auth/caddy
    copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
}
```
*(Hinweis: PocketID nutzt einen ähnlichen Endpoint für OIDC/Auth Checks).*

## 🛠️ Custom Builds mit XCaddy
Sollten wir fortgeschrittene Plugins (wie `caddy-security`) benötigen, nutzen wir ein spezialisiertes Nix-Derivat, das Caddy via `xcaddy` baut.
