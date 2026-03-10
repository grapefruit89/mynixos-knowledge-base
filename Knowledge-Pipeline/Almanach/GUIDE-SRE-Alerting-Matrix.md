---
title: 💬 SRE Alerting & Notifications (Matrix Standard)
category: architecture/monitoring
status: [ACTIVE-SSoT]
capabilities: [matrix-webhooks, automated-alerting, system-health]
sources: [https://github.com/Mic92/matrix-hook]
---

# 💬 SRE Alerting: Der Matrix-Standard

Ein Aviation-Grade System meldet sich selbstständig, wenn etwas schiefläuft. Wir nutzen Matrix als zentralen Kommunikationskanal.

## 🚀 Das Webhook-Prinzip
Wir nutzen `matrix-hook`, um einfache HTTP-POST Anfragen in Matrix-Nachrichten umzuwandeln.
- **Vorteil:** Jedes Script (Bash, Python, Nix) kann Alarme senden.

## 🛠️ Einsatzszenarien (Layer 80)
1.  **Backup-Status:** Bestätigung über erfolgreiche Backups oder Fehlermeldungen.
2.  **SRE-Audits:** Monatliche Berichte über die Systemreinheit (SRE Tor 6).
3.  **Sicherheit:** Benachrichtigung bei SSH-Logins oder Sops-Zugriffen.

## 🧩 Implementierung
Der `matrix-hook` Dienst wird in `modules/80-monitoring/notifications.nix` definiert und via Sops-Secrets (Token) abgesichert.