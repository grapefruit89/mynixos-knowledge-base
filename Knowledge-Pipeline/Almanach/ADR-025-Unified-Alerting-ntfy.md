# [ADR-025]: Unified SRE Alerting Standard (ntfy)
# ID: [ADR-025] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir führen `ntfy` als unseren zentralen Benachrichtigungsdienst für System-Alerts und Automatisierungen ein. Es ermöglicht uns, Push-Benachrichtigungen an Smartphones oder Desktops zu senden, ohne auf schwere Cloud-Dienste oder komplexe Mail-Server angewiesen zu sein.

## 2. Technical Layer (Spezifikation)
- **Target:** MyNixOS Layer 80 (Monitoring/Alerting).
- **Tool:** `pkgs.ntfy-sh` / `services.ntfy-sh.enable`.
- **Protocol:** HTTP-basiertes Pub-Sub.
- **Vorteil:** Go-Native Single-Binary, extrem leichtgewichtig, keine externe Datenbank nötig (SQLite optional).
- **Integration:** Gatus (ADR-022) nutzt `ntfy` als Alert-Backend.

## 3. Reasoning Layer (ADR)
- **[REJECTED]:** Gotify. Grund: `ntfy` bietet eine bessere UX (iOS Support via WebPush/App) und eine einfachere CLI-Integration via `curl`.
- **[DEPRECATED]:** Klassischer E-Mail-Versand für Alerts. Zu fehleranfällig und schwer zu konfigurieren (SMTP-Auth, Spam-Filter).
- **Security:** Wir betreiben `ntfy` lokal auf dem Fujitsu Q958 hinter Caddy (ADR-005) mit TLS.

---
> [SOURCE]: https://github.com/awesome-selfhosted/awesome-selfhosted
> [NUGGET-ID]: [NUGGET-SRE-008]
