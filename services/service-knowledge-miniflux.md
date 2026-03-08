---
title: "Service: Miniflux (Aviation-Grade RSS Reader)"
category: "services"
tags: [knowledge, rss, news, socket-activation, dendritic]
id: "NIXH-50-KNW-002"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["50-knowledge/service-app-miniflux.nix"]
---

# Service: Miniflux (RSS Reader)

## 1. User Layer (KISS)
Miniflux ist dein schlanker Nachrichten-Manager. Er sammelt alle Artikel deiner Lieblingsseiten an einem Ort. Er verbraucht keine Ressourcen, solange du ihn nicht nutzt (Wacht erst bei Zugriff auf).

## 2. Technical Layer (Aviation-Grade)

### Architektur & Ressourcen
* **Socket-Activation:** Nutzt systemd.sockets für effizienten Betrieb.
* **Backend:** PostgreSQL (Layer 20) mit automatischen Migrationen.
* **Auth:** Sichere Admin-Credentials via sops-nix.

### SRE Hardening
* **Sandbox:** DynamicUser = true und ProtectSystem = "strict".
* **Isolation:** Keine persistenten User-Daten außer in der Datenbank.

## 3. Reasoning Layer (History)

### [ADR-064] Socket Activation for Web Apps
Zur Maximierung der Dienst-Dichte auf dem Fujitsu Q958 werden alle kompatiblen Go-Dienste via Socket-Activation betrieben.
