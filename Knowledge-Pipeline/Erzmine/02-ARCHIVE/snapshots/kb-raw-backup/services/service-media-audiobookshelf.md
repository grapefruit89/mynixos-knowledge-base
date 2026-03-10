---
title: "Service: Audiobookshelf (Audiobooks & Podcasts)"
category: "services"
tags: [media, audiobooks, podcasts, dendritic]
id: "NIXH-40-MED-002"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["40-media/service-app-audiobookshelf.nix"]
---

# Service: Audiobookshelf (Your Private Audible)

## 1. User Layer (KISS)
Audiobookshelf ist deine private Bibliothek für Hörbücher und Podcasts. Es merkt sich deinen Fortschritt und erlaubt das Streamen auf alle deine Geräte. Alles ist so eingestellt, dass deine Bibliothek sicher auf den HDDs liegt, während die Datenbank schnell auf der SSD arbeitet.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Pfade
* **Backend:** Natives NixOS-Modul mit lokaler Datenbank.
* **Storage:** /mnt/media/books und /mnt/media/podcasts (Tier C).
* **Gruppe:** Nutzt die media-Gruppe für geteilten Zugriff.

### SRE Hardening
* **Isolation:** ProtectSystem = "strict" und begrenzte Schreibrechte (ReadWritePaths).
* **Proxy:** Caddy + Pocket-ID SSO für administrative Aufgaben.

## 3. Reasoning Layer (History)

### [ADR-062] Audiobookshelf vs. Jellyfin for Audio
Audiobookshelf bietet eine spezialisierte Handhabung von Hörbuch-Metadaten und eine native Fortschritts-Synchronisation für Podcasts, die Jellyfin aktuell nicht in dieser Tiefe liefert.
