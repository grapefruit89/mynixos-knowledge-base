---
title: 📊 InfluxDB 3: High-Performance Telemetry (Layer 80-monitoring)
category: architecture/monitoring
status: [PROPOSED]
capabilities: [time-series-database, high-granularity, netdata-backend, long-term-retention]
sources: [ipv64.net (Dennis Schröder), Influxdata Docs]
---

# 📊 InfluxDB 3: Das Gedächtnis deiner Hardware

In mynixos nutzen wir InfluxDB 3 als hocheffizienten Speicher für Telemetrie-Daten des Fujitsu Q958.

## 🏛️ 1. Warum InfluxDB 3?
- **Speed:** Massive Performance-Steigerung gegenüber Version 2. ✅
- **Storage:** Optimierte Kompression für Zeitreihen-Daten.
- **Nix-Native:** Integration via \`services.influxdb\` Modul.

## ⚙️ 2. Architektur-Integration
InfluxDB fungiert als Senke für:
1. **Netdata Metriken:** Sekündliche CPU/RAM/Disk-Daten (Kapitel 63).
2. **Gatus Health-Logs:** Historie der Dienst-Verfügbarkeit (Kapitel 76).
3. **Smartd Events:** Langzeit-Trend der HDD-Gesundheit.

## 🚀 SRE-Anwendung
Die Datenbank liegt auf **Tier A (ZFS NVMe)**, um maximale Schreib-Performance zu garantieren. Durch die Kompression bleibt der State dennoch klein (< 5GB), was unser **Offsite-Backup Mandat (ADR-015)** unterstützt.