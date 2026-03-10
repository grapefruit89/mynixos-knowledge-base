---
title: Tailscale Automation Patterns (ironicbadger Edition)
category: architecture/networking
capabilities: [mesh-vpn, tailnet-automation, acl-management]
sources: [https://github.com/ironicbadger/nix-config, ironicbadger Podcasts]
---

# 🌐 Tailscale Mastery: ironicbadger's Networking Logic

Alex Kretzschmar nutzt Tailscale als primäre Zugangsschicht.

## 🛡️ SRE-Nuggets (Tailnet Logic)
- **Tailscale-SSH:** Er ersetzt klassisches SSH durch Tailscale-SSH, um die Key-Verwaltung zu zentralisieren.
- **MagicDNS:** Integration von AdGuardHome und Tailscale MagicDNS für lokale Namensauflösung ohne IP-Frickelei.
- **ACL as Code:** Patterns zur deklarativen Verwaltung von Tailnet-Zugriffsregeln.

## 🚀 Warum wichtig für mynixos?
- Wir nutzen Tailscale in Layer 20-server. Alex' Patterns zeigen uns, wie wir den Tower komplett vom öffentlichen Internet isolieren (Zero-Trust), während er über dein Tailnet überall erreichbar bleibt.
