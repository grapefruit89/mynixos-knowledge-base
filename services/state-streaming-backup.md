# ☁️ Service: Encrypted State-Streaming (Restic)

Dieses System realisiert das "State-Streaming", um den minimalen Systemzustand (< 10GB) verschlüsselt in die Cloud zu spiegeln.

## 🛠️ Setup & Automatisierung
Das System nutzt **Restic** in Kombination mit S3-kompatiblem Speicher (z.B. Cloudflare R2 oder Backblaze B2).

### Backup-Skript (`restic-cloud-sync.sh`)
```bash
#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="/mnt/tier-a/state"
HEALTHCHECK_URL="https://hc-ping.com/YOUR_CODE"

# Backup-Lauf
if restic backup "$SOURCE_DIR" --tag "auto-sync"; then
    # Lifecycle Management (Retention Policy)
    restic forget --keep-daily 7 --keep-weekly 4 --prune
    # Herzschlag-Signal (Dead Man's Switch)
    curl -fsS -m 10 --retry 5 "$HEALTHCHECK_URL"
fi
```

## 📊 Monitoring (Homepage Dashboard)
Der Status des letzten Syncs wird in eine JSON-Datei geschrieben und vom Dashboard visualisiert.

> [LIVE-ENRICHMENT]: Laut Restic Best-Practices (v0.16+) sollte für S3-Backups immer die Umgebungsvariable `AWS_X_AMZ_CONTENT_SHA256` genutzt werden, um die Integrität beim Upload auf Cloudflare R2 zu garantieren.

## 🧠 Learnings
- **Henne-Ei-Problem:** WLAN-Keys müssen auf dem Stick liegen, damit das System überhaupt die Cloud für den restlichen State erreichen kann.
- **State-Explosion:** `/var/log` sollte auf `tmpfs` liegen, um das 10GB Cloud-Limit nicht durch Logs zu sprengen.
