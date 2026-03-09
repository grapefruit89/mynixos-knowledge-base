---
title: 📊 Gatus: Next-Gen Monitoring (Layer 80-monitoring)
category: architecture/monitoring
status: [PROPOSED]
capabilities: [single-binary, yaml-config, health-checks, status-page]
sources: [r/selfhosted Trends 2026, Gatus GitHub]
---

# 📊 Gatus: Der hocheffiziente Watchtower

In mynixos evaluieren wir Gatus als hocheffiziente Alternative zu Uptime Kuma. Es folgt dem **Binary-Efficiency-Mandat** und dem **No-UI-Config Standard**.

## 🏛️ 1. Warum Gatus?
- **Technologie:** In Go geschrieben. ✅
- **Konfiguration:** Rein deklarativ via YAML (kein Herumklicken in einer UI nötig).
- **Ressourcen:** Minimaler RAM-Footprint im Vergleich zu Node.js-basierten Lösungen.

## ⚙️ 2. Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/80-monitoring/gatus.nix\`):

\`\`\`nix
services.gatus = {
  enable = true;
  settings = {
    endpoints = [
      {
        name = "Caddy Gateway";
        url = "https://m7c5.de";
        interval = "1m";
        conditions = [ "[STATUS] == 200" ];
      }
      {
        name = "Jellyfin";
        url = "http://localhost:8096/health";
        interval = "1m";
        conditions = [ "[STATUS] == 200" ];
      }
    ];
  };
};
\`\`\`

## 🛡️ 3. SRE-Vorteil
Da Gatus seine gesamte Konfiguration aus einer Datei liest, ist es zu 100% reproduzierbar. Ein Rollback deines NixOS-Flakes stellt auch sofort alle deine Health-Checks wieder her. ✅

## 🚀 SRE-Anwendung
Gatus wird via Caddy unter \`status.m7c5.de\` öffentlich (oder via VPN) zugänglich gemacht. Es dient als SSoT für die Verfügbarkeit deiner Dienste.