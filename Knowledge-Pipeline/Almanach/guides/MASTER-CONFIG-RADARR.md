---
title: 📚 Radarr MASTER-VARIABLE-LIST (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/Radarr/Radarr]
---

# 📚 Radarr: Konfigurations-Referenz

RADARR_CONSOLE_PROCESS_NAME
RADARR__LOG__CONSOLEFORMAT
RADARR_PROCESS_NAME
RADARR_TESTS_LOG_OUTPUT

## 🚀 SRE-Anwendung
Radarr wird in NixOS primär über \`services.radarr\` gesteuert.
- **Port:** Standard 7878.
- **DataDir:** Standard \`/var/lib/radarr\`.