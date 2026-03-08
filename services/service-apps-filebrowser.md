---
title: "Service: Filebrowser (Aviation-Grade File Management)"
category: "services"
tags: [knowledge, files, management, dendritic]
id: "NIXH-60-APP-003"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["60-apps/service-app-filebrowser.nix"]
---

# Service: Filebrowser (Web Explorer)

## 1. User Layer (KISS)
Filebrowser ist dein "Windows Explorer" im Browser. Er erlaubt es dir, Dateien auf deinem Server hochzuladen, zu löschen oder umzubenennen, ohne dass du dich mit Linux-Befehlen auskennen musst. Das Modul sorgt dafür, dass du nur auf die freigegebenen Speicherbereiche (deinen Datenpool) zugreifen kannst und alles durch mTLS und SSO geschützt ist.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Pfade
*   **Modus:** Natives NixOS-Modul (`services.filebrowser`).
*   **Root-Verzeichnis:** `/mnt/storage` (Dein globaler JBOD-Pool).
*   **Datenbank:** `/var/lib/filebrowser/filebrowser.db` (Speichert Nutzer und Einstellungen).

### SRE Hardening & Security
*   **Netzwerk:** Lauscht nur auf `127.0.0.1`. Ingress via Caddy.
*   **Sandboxing:** Nutzt `ProtectSystem = "strict"` und `PrivateDevices = true`.
*   **Pfad-Einschränkung:** Schreibrechte sind via systemd `ReadWritePaths` auf `/var/lib/filebrowser` und den Haupt-Datenpool beschränkt.

### Integration (Nix-Snippet)
```nix
services.filebrowser = {
  enable = true;
  settings = {
    port = port;
    root = "/mnt/storage";
  };
};
```

## 3. Reasoning Layer (History)

### [ADR-070] Filebrowser vs. Nextcloud
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Nextcloud ist eine vollwertige Suite, aber oft zu langsam für einfaches Dateimanagement.
*   **Entscheidung:** Nutzung von Filebrowser für den direkten Zugriff auf den Storage-Pool.
*   **Vorteil:** Extrem schnell, keine Abhängigkeit von komplexen Datenbanken oder PHP-Stacks. Ideal für das schnelle Verschieben von Mediendateien im Heimnetz.

---
**Community-Abgleich:** Konform zu NixOS Modul-Standards für ressourcenschonende Datei-Verwaltung.
