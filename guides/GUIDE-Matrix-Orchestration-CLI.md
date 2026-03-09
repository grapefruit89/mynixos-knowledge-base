---
title: 🤖 Matrix Orchestration & Alerting (Layer 30-automation)
category: architecture/automation
status: [ACTIVE-SSoT]
capabilities: [e2ee-alerting, system-voice, automated-logs, cli-matrix]
sources: [nixpkgs/pkgs/applications/networking/instant-messengers/matrix-commander, matrix-hook]
---

# 🤖 System-Kommunikation: Der Tower spricht

In mynixos ist der Matrix-Homeserver (Conduit) nicht nur zum Chatten da. Er ist die zentrale Pipeline für alle SRE-Warnungen und System-Statusberichte.

## 🏛️ 1. Das Alerting-Konzept (Aviation-Grade)
Wir trennen zwischen zwei Workflows:
- **Matrix-Hook (High-Speed):** Für einfache Status-Messages via \`curl\`.
- **Matrix-Commander (Secure):** Für verschlüsselte (E2EE) Berichte und Datei-Uploads (z.B. Backup-Logs).

## ⚙️ 2. Matrix-Commander (The Secure Voice)
- **Tool:** \`pkgs.matrix-commander\`.
- **Anwendung:**
\`\`\`bash
matrix-commander --message "🚨 SRE Alert: SMART Check auf Tier-C HDD fehlgeschlagen!"
\`\`\`
- **SRE-Vorteil:** Unterstützt native Verschlüsselung. Deine kritischen System-Interna verlassen den Tower niemals im Klartext. ✅

## 🏷️ 3. Integration in Layer 80 (Monitoring)
Wir binden den Commander in unsere systemd-Timer ein:
- **Backup-Success:** Sendet eine grüne Nachricht nach jedem erfolgreichen Restic-Run.
- **Fail2ban-Alert:** Sendet die IP-Adresse bei einer permanenten Sperrung.
- **Update-Check:** Informiert über neue NixOS-Releases.

## 🚀 SRE-Anwendung
Der Matrix-Commander folgt dem **Headless-Gesetz (ADR-010)**. Er benötigt keinen Desktop und ist die stabilste Schnittstelle zwischen deinem Server und deinem Smartphone.