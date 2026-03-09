---
title: 📊 Uptime Kuma Master-Config (Layer 80-monitoring)
category: architecture/monitoring
status: [ACTIVE-SSoT]
capabilities: [service-monitoring, health-checks, matrix-alerting]
sources: [https://github.com/louislam/uptime-kuma, official nixpkgs modules]
---

# 📊 Uptime Kuma: Der Watchtower deines Towers

In mynixos ist Uptime Kuma das zentrale Dashboard für die Verfügbarkeit deiner Dienste.

## 🏛️ Architektur-Entscheidungen (SRE Standard)
1.  **SQLite-First:** Wir nutzen die eingebettete SQLite Datenbank für minimalen RAM-Verbrauch.
2.  **Internal Only:** Das Dashboard ist nur via Tailnet oder gehärtetem Caddy-Ingress erreichbar.
3.  **Alerting:** Integration mit \`matrix-hook\` oder Apprise für sofortige SRE-Notifications.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/80-monitoring/uptime-kuma.nix\`):

\`\`\`nix
services.uptime-kuma = {
  enable = true;
  settings = {
    UPTIME_KUMA_PORT = \"3001\";
    UPTIME_KUMA_HOST = \"127.0.0.1\";
  };
};
\`\`\`

## 🛠️ Extrahierte Variablen (Auszug)
Folgende Steuer-Flags stehen zur Verfügung:
- UPTIME_KUMA_DB_TYPE
- UPTIME_KUMA_DISABLE_FRAME_SAMEORIGIN
- UPTIME_KUMA_CLOUDFLARED_TOKEN (für Ingress-Monitoring)
