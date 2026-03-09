---
title: ADR-005: Hybrid Identity (Tailscale Auth + PocketID)
status: [ACCEPTED]
category: architecture/decision
capabilities: [tailscale-auth, oidc, zero-friction-access]
sources: [ironicbadger pms-wiki, Tailscale WhoIs documentation]
---

# 🏛️ ADR-005: Hybrid Identity Modell

## Kontext
Wir wollen den Login-Widerstand minimieren. Ironicbadger nutzt Tailscale WhoIs, um Authentifizierung für Tailnet-Nutzer unsichtbar zu machen.

## Entscheidung
Wir implementieren ein zweistufiges Identitäts-Modell:
1.  **Admin-Layer (Tailscale):** Zugriff auf Management-Tools (Cockpit, Scrutiny, Tower-SSH) erfolgt ohne Login via **Tailscale Auth**.
2.  **Guest-Layer (PocketID):** Zugriff auf geteilte Dienste (Jellyfin, Nextcloud) für externe Nutzer erfolgt via **PocketID (Passkeys)** über Cloudflare Tunnels.

## Begründung
- **Zero-Friction:** Du musst dich auf deinen eigenen Geräten niemals einloggen.
- **Sicherheit:** Tailscale-Verbindungen sind bereits Ende-zu-Ende verschlüsselt und identitätsgeprüft.
- **Flexibilität:** PocketID deckt den Bedarf für Nutzer ohne Tailscale ab.

## Konsequenz
In \`modules/20-server/caddy.nix\` wird eine Logik implementiert, die den Tailscale-Status prüft, bevor sie den PocketID-Forward-Auth erzwingt.