---
title: 📚 Vaultwarden MASTER-CONFIG (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/dani-garcia/vaultwarden]
---

# 📚 Vaultwarden: Passwort-Sicherheit

Vaultwarden nutzt eine zentrale Environment-Datei zur Konfiguration.

## ⚙️ SRE-Anwendung
In NixOS nutzen wir \`services.vaultwarden\`.
- **Datenbank:** Standard SQLite (Aviation-Grade Efficiency).
- **Hardening:** \`services.vaultwarden.config\` erlaubt das Setzen aller Variablen (z.B. \`SIGNUPS_ALLOWED = false\`).