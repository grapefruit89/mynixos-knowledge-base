---
title: "Service: Prowlarr (Indexer-Manager)"
category: "services"
tags: [media, indexer, sonarr, radarr, dendritic]
id: "NIXH-40-MED-011"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["40-media/service-media-prowlarr.nix"]
---

# Service: Prowlarr (The Switchboard)

## 1. User Layer (KISS)
Prowlarr ist die Schaltzentrale für deine Suchquellen (Indexer). Anstatt jeden Indexer einzeln in Sonarr oder Radarr einzutragen, machst du das zentral in Prowlarr. Es verteilt die Einstellungen automatisch an alle Sammler.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Automation
* **Rolle:** Aggregator für Torrent- und Usenet-Indexer.
* **Sync:** Nutzt die Arr-Wire API-Logik zur automatischen Konfiguration der Clients.
* **Backend:** .NET Core Anwendung, optimiert für schnelles Indexing.

### SRE Hardening
* **Sandbox:** Nutzt DynamicUser = true. Es verbleiben keine permanenten User-Überreste im System.
* **Isolation:** Strenge systemd-Unit Isolation (mkServarrHardening).

## 3. Reasoning Layer (History)

### [ADR-061] Prowlarr vs. Jackett
Prowlarr wurde gewählt, weil es Indexer aktiv in die Clients "pushen" kann, anstatt nur passiv abgefragt zu werden. Dies stellt sicher, dass alle Arrr-Dienste immer synchrone Quellen nutzen.
