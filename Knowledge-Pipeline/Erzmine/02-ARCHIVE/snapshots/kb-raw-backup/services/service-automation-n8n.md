---
title: "Service: n8n (Aviation-Grade Workflow Automation)"
category: "services"
tags: [automation, n8n, workflows, postgresql, dendritic]
id: "NIXH-30-AUT-004"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/30-automation/service-app-n8n.nix"]
---

# Service: n8n (Workflow Engine)

## 1. User Layer (KISS)
n8n ist dein „digitaler Butler“. Es verbindet verschiedene Apps und Dienste miteinander, um Aufgaben automatisch zu erledigen (z.B. „Wenn eine neue E-Mail mit einer Rechnung kommt, speichere den Anhang in Paperless“). Dieses Modul sorgt dafür, dass n8n sicher auf deinem Server läuft, seine Daten in deiner PostgreSQL-Datenbank speichert und durch mTLS/SSO vor unbefugtem Zugriff geschützt ist.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Backend
*   **Datenbank:** Nutzt PostgreSQL (Layer 20) via UNIX-Socket für maximale Performance und Sicherheit.
*   **Ressourcen:** Optimiertes Node.js Memory-Management (`N8N_NODE_OPTIONS = --max-old-space-size=2048`).
*   **Maintenance:** Automatische Bereinigung alter Ausführungsdaten nach 14 Tagen (`EXECUTIONS_DATA_MAX_AGE = 336`).

### SRE Hardening
*   **Isolation:** Nutzt `DynamicUser = true` – der Dienst läuft unter einem temporären Benutzer ohne Schreibrechte außerhalb von `/var/lib/n8n`.
*   **Netzwerk:** Das Web-Interface ist via Caddy + Pocket-ID SSO abgesichert.
*   **Systemd Sandbox:** Strikte Beschränkung der AddressFamilies und `ProtectSystem = strict`.

### Integration (Nix-Snippet)
```nix
services.n8n = {
  enable = true;
  environment = {
    DB_TYPE = "postgresdb";
    DB_POSTGRESDB_HOST = "/run/postgresql";
  };
};
```

## 3. Reasoning Layer (History)

### [ADR-055] PostgreSQL vs. SQLite for n8n
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Bei komplexen Workflows und vielen gleichzeitigen Ausführungen stößt SQLite an seine Grenzen (Locking).
*   **Entscheidung:** Nutzung der zentralen PostgreSQL-Instanz.
*   **Vorteil:** Höhere Zuverlässigkeit und einfachere Integration in die globale Backup-Strategie.

---
**Community-Abgleich:** Konform zu `nixpkgs/nixos/modules/services/misc/n8n.nix`.
