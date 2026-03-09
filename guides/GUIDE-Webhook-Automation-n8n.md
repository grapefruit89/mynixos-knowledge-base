---
title: 🔗 Webhook Orchestrierung (n8n & Caddy)
category: architecture/automation
status: [ACTIVE-SSoT]
capabilities: [instant-deployment, real-time-alerting, event-driven-sre]
sources: [GitHub Webhook Documentation, n8n Docs]
---

# 🔗 Webhooks: Die Nervenbahnen deines Systems

Webhooks verbinden deinen externen Code (GitHub) mit der physischen Realität deines Towers.

## 🏛️ 1. Der Workflow (GitHub -> n8n)
Wir nutzen n8n als zentralen Event-Handler.
1. **GitHub:** Sendet POST-Paket bei Push-Event.
2. **Caddy (Layer 10):** Reicht die Anfrage sicher an n8n weiter (\`hooks.m7c5.de\`).
3. **n8n (Layer 30):** Verarbeitet die Daten und triggert Aktionen (Matrix-Nachricht, System-Update).

## 🚀 2. Aviation-Grade Anwendungen
- **Auto-Rebuild:** Trigger für \`nixos-rebuild\` bei Änderungen am Master-Branch. ✅
- **Emergency-Shutdown:** Ein Webhook, der von einer externen Monitoring-Instanz kommt, falls der Tower überhitzt.
- **Sync-Kickstart:** Startet den Offsite-Backup-Sync manuell via externem Signal.

## 🛡️ 3. Security (HMAC-Validation)
Webhooks sind nur sicher, wenn wir die Herkunft prüfen.
- **Geheimnis:** Wir hinterlegen ein Webhook-Secret in GitHub.
- **Prüfung:** n8n validiert die \`X-Hub-Signature-256\` mithilfe unseres Sops-Secrets. Unbefugte können keine Aktionen triggern. ✅

## 🚀 SRE-Anwendung
Webhooks machen deine Infrastruktur "Event-Driven". Dein Tower reagiert in Millisekunden auf Änderungen in der Cloud.