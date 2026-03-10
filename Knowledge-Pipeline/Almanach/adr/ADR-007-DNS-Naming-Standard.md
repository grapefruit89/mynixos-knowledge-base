---
title: ADR-007: DNS- & Naming-Standard (Tailscale SplitDNS)
status: [ACCEPTED]
category: architecture/networking
capabilities: [magicdns, split-dns, adguard-integration, future-proof-routing]
sources: [https://blog.ktz.me/splitdns-magic-with-tailscale/, Internal Network Audit]
---

# 🏛️ ADR-007: Aviation-Grade DNS Management

## Kontext
Wir benötigen eine robuste Namensauflösung für Dienste auf dem Tower, die sowohl lokal als auch im Tailnet ohne manuelle IP-Eingabe funktioniert.

## Entscheidung
Wir implementieren das **Tailscale SplitDNS Pattern**:
1.  **MagicDNS:** Aktivierung für alle Tailnet-Geräte (SSoT für Hostnamen).
2.  **Global Nameserver:** Der Tower (AdGuardHome) wird als globaler Nameserver im Tailscale-Admin-Panel hinterlegt.
3.  **SplitDNS Regel:** Alle Anfragen an `m7c5.de` werden explizit an die Tailscale-IP des Towers geroutet.

## Begründung
- **Resilienz:** Namensauflösung funktioniert unabhängig vom öffentlichen DNS-Status.
- **Privacy:** Interne Dienstnamen verlassen niemals das verschlüsselte Netzwerk.
- **Zero-Touch:** Einmal konfiguriert, lösen alle Geräte im Tailnet die Dienste korrekt auf.

## Konsequenz
In `modules/10-gateway/adguardhome.nix` wird der Tower als autoritativer DNS für die lokale Zone konfiguriert.
