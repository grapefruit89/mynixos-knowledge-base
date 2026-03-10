---
title: 🌐 Tailnet Zero-Trust Standard
category: architecture/networking
status: [ACTIVE-SSoT]
capabilities: [mesh-vpn, tailscale-ssh, zero-exposed-ports]
sources: [https://github.com/ironicbadger/jankey, ironicbadger nix-config]
---

# 🌐 Tailnet Zero-Trust: Sicherer Zugang ohne Port-Forwards

In mynixos ist Tailscale das Rückgrat deines Netzwerks. Wir folgen dem Zero-Trust Prinzip: Keine offenen Ports am Router.

## 🛡️ Die Tailscale-SSH Strategie
Wir nutzen konsequent **Tailscale-SSH**.
- **Vorteil:** Authentifizierung erfolgt über dein Tailscale-Login (OIDC/Identity).
- **Sicherheit:** Kein klassischer SSH-Port (22) muss im LAN oder Internet offen sein.

## 🔍 MagicDNS & AdGuard
Der Tower nutzt Tailscale MagicDNS zur internen Namensauflösung.
- **Integration:** AdGuardHome fungiert als Upstream-DNS für das Tailnet, um Werbung systemweit zu filtern.

## 🚀 Automatisierung (Stick-Ready)
Wir nutzen Patterns aus ironicbadger's `jankey`, um den Tower beim ersten Boot via ephemeral Auth-Keys (in Sops verschlüsselt) in das Tailnet einzubinden.