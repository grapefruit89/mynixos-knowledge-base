---
title: 📊 Monitoring Hub: Gatus vs. Uptime Kuma (Layer 80)
category: architecture/monitoring
status: [ACTIVE-SSoT]
capabilities: [health-checks, status-pages, go-efficiency, declarative-monitoring]
sources: [Official Gatus NixOS Module, Reddit Trends 2026]
---

# 📊 Monitoring Hub: Dein System-Wächter

In mynixos priorisieren wir hocheffiziente Monitoring-Lösungen. Hier ist unser Standard für die Dienst-Verfügbarkeit.

## 🏆 1. Gatus (Der SRE-Standard)
Gatus ist unser primäres Tool für Health-Checks und Status-Seiten.
- **Warum:** In Go geschrieben (Binary-Effizienz), rein deklarativ via YAML/Nix steuerbar. ✅
- **NixOS-Modul:** \`services.gatus.enable = true;\`
- **SRE-Vorteil:** Keine Datenbank-Wartung nötig, minimale CPU-Last. Perfekt für den i3-9100. ✅

## 🐢 2. Uptime Kuma (Legacy Alternative)
Wir behalten Uptime Kuma nur als Option, falls eine grafische Konfiguration via Browser zwingend erforderlich ist.
- **Kritik:** Node.js-basiert (höherer RAM-Verbrauch), benötigt SQLite/MariaDB.
- **Status:** In mynixos als "Deprioritized" markiert. ❌

## ⚙️ Deklarative Gatus-Konfiguration
\`\`\`nix
services.gatus = {
  enable = true;
  settings = {
    endpoints = [
      {
        name = "Caddy Ingress";
        url = "https://m7c5.de";
        interval = "1m";
        conditions = [ "[STATUS] == 200" ];
      }
    ];
  };
};
\`\`\`

## 🚀 SRE-Anwendung
Das Monitoring-Dashboard wird via Caddy (Kapitel 58) unter \`status.m7c5.de\` exponiert und via mTLS gesichert.