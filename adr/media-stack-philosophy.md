---
title: "Media Stack Philosophy: nixarr meets nixflix"
category: "adr"
tags: [nixos, media, sonarr, radarr, architecture, nixarr, nixflix]
date: 2026-03-08
source: "claude-genesis-log-11f6d76e"
status: "verified-substance-definitive"
---

# 🏛️ [ADR-INFO]: MEDIA STACK ARCHITECTURE PHILOSOPHY

Dieses Dokument definiert den hybriden Ansatz zur Implementierung des Media-Stacks (Arrr-Apps), inspiriert durch führende Community-Projekte.

---

## 🏗️ 1. USER LAYER: DIE HYBRIDE VISION (KISS)
Wir bauen unseren Media-Server nicht komplett neu, sondern nehmen die besten Ideen der Profis:
- **Fundament:** Stabil und geordnet wie `nixarr`.
- **Intelligenz:** Automatisch konfiguriert via API wie `nixflix`.
- **Modern:** Schlank und modular wie `ironicbadger`.

---

## 🛠️ 2. TECHNICAL LAYER: DIE DREI SÄULEN

### A. Der "Rohbau" (Infrastruktur)
Wir nutzen die **nixarr-Logik** für:
- Zentrale Benutzerverwaltung (`media` user/group).
- Einheitliche Verzeichnisstruktur (`/data/media/movies`, `/data/media/tv`).
- VPN-Isolation via Network Namespaces (siehe `services/media-stack-hardening.md`).

### B. Der "Innenarchitekt" (API-Konfiguration)
Wir nutzen die **nixflix-Idee** für:
- Deklarative Einrichtung der Apps via REST-API (Sonarr ↔ Prowlarr Verbindung).
- **Recyclarr Integration:** Automatischer Sync von TRaSH-Guides für perfekte Medien-Qualität.
- PostgreSQL als Backend für alle Arrr-Services (höhere Performance bei großen Mediatheken).

### C. Der "Kurator" (Isomorphie)
Wir nutzen das **ironicbadger-Muster** für:
- Radikale Entkopplung von Code und Daten.
- SSoT (Single Source of Truth) in der `USER_CONFIG.nix`.

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum kein reines `nixarr`?
`nixarr` ist ein großartiges Modul, aber es ist eine "Blackbox". Wir wollen die volle Kontrolle über unsere Dendritic-Aspekte haben und die API-Automatisierung von `nixflix` nutzen, die in `nixarr` fehlt.

### Warum API-basierte Konfiguration?
Das manuelle Verbinden von Sonarr, Radarr, Prowlarr und SABnzbd über Web-UIs dauert Stunden und ist fehleranfällig. Durch idempotente API-Skripte (NixOS Activation Scripts) stellen wir sicher, dass das System bei jedem Boot korrekt verdrahtet ist.
