---
title: "Service: Media-ARR Stack (Sonarr & Radarr)"
category: "services"
tags: [media, tv, movies, automation, dendritic]
id: "NIXH-40-MED-STACK"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["40-media/service-media-sonarr.nix", "40-media/service-media-radarr.nix"]
---

# Service: Media-ARR Stack (Sonarr & Radarr)

## 1. User Layer (KISS)
Sonarr (Serien) und Radarr (Filme) sind deine automatischen Sammler. Sie suchen nach neuen Inhalten, laden diese herunter und sortieren sie in deine Bibliothek ein. Beide laufen sicher getrennt, teilen sich aber die Medien-Gruppe für reibungslose Datenverschiebungen.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Factory
* **Factory-Pattern:** Nutzt die servarr-factory für einheitliche Konfiguration.
* **Environment:** Direkte Injektion von Einstellungen als Umgebungsvariablen.
* **Storage:** Trennung von State (SSD) und Bibliothek (HDD Pool).

### SRE Hardening
* **Sandbox:** Nutzt mkServarrHardening (kein Root, kein Hostname-Zugriff).
* **Namespace:** Unterstützt den Betrieb in einem VPN-Namespace (netns).

## 3. Reasoning Layer (History)

### [ADR-057] Factory-driven Servarr Deployment
Die Nutzung einer zentralen Factory reduziert Codeduplikation und garantiert ein identisches Sicherheitslevel über alle Arrr-Dienste hinweg.
