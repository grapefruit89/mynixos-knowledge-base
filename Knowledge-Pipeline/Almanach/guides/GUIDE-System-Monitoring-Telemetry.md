---
title: 📈 System Monitoring & Telemetry (Layer 80-monitoring)
category: architecture/monitoring
status: [ACTIVE-SSoT]
capabilities: [real-time-metrics, igpu-monitoring, data-recovery, log-externalization]
sources: [nixpkgs/pkgs/tools/system, netdata docs, nvtop intel support]
---

# 📈 Monitoring: Die Augen des SRE

In mynixos lassen wir keine Komponente unbeobachtet. Wir nutzen hocheffiziente Werkzeuge, um die Gesundheit des Towers (Fuji Q958) zu garantieren.

## 🏛️ 1. Echtzeit-Performance via Netdata
Wir nutzen Netdata für die totale Transparenz ohne merkliche CPU-Last.
- **Dienst:** \`services.netdata.enable = true;\`
- **SRE-Vorteil:** Visualisiert Hardware-Metriken (CPU C-States, ZFS-ARC, Disk-Latency) im Web-UI auf Port 19999. ✅

## 📽️ 2. iGPU Monitoring (\`nvtop\`)
Um den Erfolg von Kapitel 51 (QuickSync) zu überwachen.
- **Tool:** \`pkgs.nvtopPackages.intel\`.
- **Befehl:** \`nvtop\` zeigt die Auslastung des Video-Engines und des Grafik-RAMs in einer htop-ähnlichen Ansicht. ✅

## 🛡️ 3. Disaster Recovery (\`testdisk\`)
Unsere Lebensversicherung für den Storage-Layer (ADR-006).
- **Anwendung:** Wird nicht als Dienst gestartet, ist aber im SRE-Profil (\`environment.systemPackages\`) vorinstalliert.
- **Zweck:** Wiederherstellung von gelöschten Partitionen oder Dateien auf Tier-C.

## 🚀 SRE-Anwendung
Das Monitoring ist via Caddy (Kapitel 58) unter \`stats.m7c5.de\` erreichbar und durch mTLS sowie Pocket-ID geschützt.