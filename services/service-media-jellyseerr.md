---
title: "Service: Jellyseerr (Media Request Management)"
category: "services"
tags: [media, requests, jellyfin, radarr, sonarr, dendritic]
id: "NIXH-40-MED-008"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["40-media/service-media-jellyseerr.nix"]
---

# Service: Jellyseerr (Discovery & Requests)

## 1. User Layer (KISS)
Jellyseerr ist deine "Wunschliste". Hier findest du neue Filme und Serien und kannst sie mit einem Klick anfordern. Das System prüft automatisch, ob der Inhalt bereits da ist, oder gibt ihn an Sonarr/Radarr weiter.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Ingress
* **Backend:** Natives NixOS-Modul auf Node.js Basis.
* **Integration:** Direkte API-Anbindung an Jellyfin, Sonarr und Radarr.
* **Discovery:** Nutzt TMDB-Metadaten für Poster und Trailer.

### SRE Hardening
* **Isolation:** ProtectSystem = "strict" und StateDirectory Isolierung.
* **Proxy:** Absicherung via Caddy. Kann optional für externe Nutzer ohne SSO (nur Jellyfin-Auth) freigegeben werden.

## 3. Reasoning Layer (History)

### [ADR-060] Jellyseerr vs. Ombi
Jellyseerr wurde aufgrund der besseren Jellyfin-Integration und der moderneren Benutzeroberfläche gewählt. Es bietet zudem eine bessere Performance bei großen Bibliotheken.
