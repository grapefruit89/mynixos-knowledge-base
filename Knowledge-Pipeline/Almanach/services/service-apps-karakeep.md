---
title: "Service: Karakeep (Aviation-Grade Bookmark Manager)"
category: "services"
tags: [knowledge, bookmarks, dendritic]
id: "NIXH-60-APP-004"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["60-apps/service-app-karakeep.nix"]
---

# Service: Karakeep (Bookmark Archive)

## 1. User Layer (KISS)
Karakeep ist dein privater Tresor für Internet-Links. Anstatt Lesezeichen im Browser zu speichern, die du auf anderen Geräten nicht findest, sammelst du sie zentral in Karakeep. Das Modul sorgt dafür, dass deine Sammlung privat bleibt, niemand fremdes Konten anlegen kann und du deine Links über ein schönes Web-Interface verwalten kannst.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Konfiguration
*   **Modus:** Natives NixOS-Modul (`services.karakeep`).
*   **Signups:** Öffentliche Registrierungen sind deaktiviert (`DISABLE_SIGNUPS = "true"`).
*   **Netzwerk:** Der Dienst lauscht auf einem dynamischen Port aus dem globalen Port-Register (`config.my.ports.karakeep`).

### Ingress & Security
*   **Proxy-Pflicht:** Zugriff nur über Caddy mit Pocket-ID SSO Authentifizierung.
*   **Isolation:** Läuft standardmäßig in einer systemd-Sandbox des offiziellen Moduls.

### Integration (Nix-Snippet)
```nix
services.karakeep = {
  enable = true;
  extraEnvironment = {
    PORT = toString port;
    DISABLE_SIGNUPS = "true";
  };
};
```

## 3. Reasoning Layer (History)

### [ADR-069] Karakeep vs. Linkding
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Linkding ist der Platzhirsch bei den Lesezeichen-Managern.
*   **Entscheidung:** Nutzung von Karakeep.
*   **Vorteil:** Karakeep bietet eine extrem schlichte, ablenkungsfreie Benutzeroberfläche und lässt sich nahtlos in das NIXHOME-System integrieren, ohne komplexe Datenbank-Backends vorauszusetzen.

---
**Community-Abgleich:** Konform zu NixOS Modul-Vorgaben für Web-Applikationen.
