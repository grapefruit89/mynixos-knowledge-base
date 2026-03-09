---
title: 🧹 Data Deduplication & Hygiene (Layer 80-monitoring)
category: architecture/storage
status: [ACTIVE-SSoT]
capabilities: [duplicate-finding, storage-optimization, headless-hygiene]
sources: [rclone dedupe docs, SRE Storage Patterns]
---

# 🧹 Daten-Hygiene: Krieg den Duplikaten

In mynixos verzichten wir auf grafische Tools wie dupeguru. Wir nutzen hocheffiziente CLI-Werkzeuge, um den Speicherplatz auf Tier C (HDDs) zu optimieren.

## 🏛️ 1. Die SSoT-Lösung: rclone dedupe
Für das Finden und Löschen von identischen Dateien in deinem Medien-Pool.
- **Befehl:** \`rclone dedupe /mnt/storage/media\`
- **Modi:**
    - \`interactive\`: Fragt bei jedem Fund nach.
    - \`first\`: Behält die erste Datei (schnell).
    - \`newest\`: Behält die neueste Datei.
    - \`largest\`: Behält die größte Datei.

## ⚡ 2. Warum rclone statt dupeguru?
- **Headless:** Läuft perfekt via SSH. ✅
- **Cloud-Ready:** Funktioniert auch auf deinen S3-Buckets (Garage) oder Cloud-Backups. ✅
- **Efficiency:** Verbraucht minimal RAM im Vergleich zu Qt-basierten Apps.

## ⚙️ 3. Automatisierung (SRE-Weg)
Wir können \`rclone dedupe --dry-run\` als monatlichen systemd-Timer (Layer 80) einrichten, der uns via Matrix (Kapitel 20) informiert, wenn signifikante Mengen an Duplikaten gefunden wurden.

## 🚀 SRE-Vorteil
Das System bleibt sauber und folgt dem **Headless-Gesetz (ADR-010)**.