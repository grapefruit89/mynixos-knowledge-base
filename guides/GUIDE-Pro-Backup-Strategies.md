---
title: 🛡️ Pro-Backup & Storage Patterns (Aviation-Grade)
category: architecture/storage
status: [ACTIVE-SSoT]
capabilities: [ransomware-protection, cloud-mounts, append-only-backups]
sources: [https://github.com/restic/rest-server, https://github.com/rclone/rclone]
---

# 🛡️ Pro-Backup: Die Festung für deine Daten

Wir nutzen die Strategien der Profis, um Datenverlust physisch unmöglich zu machen.

## 🏛️ 1. Ransomware-Schutz via Rest-Server
Der Tower agiert als Restic-Ziel für alle deine Geräte.
- **Dienst:** \`services.restic.rest-server.enable = true;\`
- **Pattern:** Wir nutzen den \`--append-only\` Modus. Clients dürfen neue Daten schreiben, aber niemals alte Daten löschen oder überschreiben.
- **SRE-Sicherheit:** Selbst ein kompromittiertes Endgerät kann deine Backup-Historie nicht zerstören.

## ☁️ 2. Cloud-Mounting (The Rclone VFS Standard)
Für den Zugriff auf Tier-C Daten in der Cloud (z.B. S3/B2) nutzen wir optimierte Mount-Flags:
\`\`\`bash
rclone mount remote:bucket /mnt/cloud \
  --vfs-cache-mode full \
  --vfs-cache-max-age 24h \
  --dir-cache-time 1000h \
  --attr-timeout 1000h
\`\`\`
- **Vorteil:** Minimale API-Calls (Kostenersparnis) und sofortiger Start von Medien-Streams.

## 🔄 3. Rsync Atomic Sync
Für lokale Migrationen zwischen Platten nutzen wir:
\`\`\`bash
rsync -av --inplace --sparse --progress /src /dest
\`\`\`
- **Vorteil:** Schont den ZFS-ARC und ist effizient bei großen Mediendateien.