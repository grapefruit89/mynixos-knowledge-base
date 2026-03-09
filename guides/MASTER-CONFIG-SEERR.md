---
title: 📚 Jellyseerr MASTER-VARIABLE-LIST (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/seerr-team/seerr]
---

# 📚 Jellyseerr: Konfigurations-Referenz

API_KEY
CONFIG_DIRECTORY
DB_HOST
DB_NAME
DB_PASS
DB_PORT
DB_SOCKET_PATH
DB_TYPE
DB_USER
DB_USE_SSL
HOST
JELLYFIN_TYPE
LOG_LEVEL
NODE_ENV
PORT
PRESERVE_DB
TZ
WITH_MIGRATIONS

## 🚀 SRE-Anwendung
In NixOS nutzen wir für Jellyseerr oft \`services.jellyseerr\`. Die Variablen können wir via \`systemd.services.jellyseerr.environment\` injizieren.