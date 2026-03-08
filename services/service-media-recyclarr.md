---
title: "Service: Recyclarr (Quality Profile Automation)"
category: "services"
tags: [media, quality, trash-guides, dendritic]
id: "NIXH-40-MED-014"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["40-media/service-media-recyclarr.nix"]
---

# Service: Recyclarr (Quality Automation)

## 1. User Layer (KISS)
Recyclarr sorgt dafür, dass Sonarr und Radarr immer die beste Qualität finden. Er lädt automatisch die empfohlenen Einstellungen der Community herunter und hält deine Profile aktuell, ohne dass du etwas tun musst.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Synchronisation
* **Modus:** Natives NixOS-Modul mit automatischer Profile-Pflege.
* **Profile:** Nutzt die TRaSH-Guide Templates für optimale Formate.
* **Secrets:** Sicherer Import der API-Keys via systemd LoadCredential (sops-nix).

### SRE Hardening
* **Resource:** Begrenzt auf 512MB RAM.
* **Privacy:** Keine Klarschrift-Keys in Umgebungsvariablen.

## 3. Reasoning Layer (History)

### [ADR-063] Declarative Quality Profiles
Die Steuerung der Profile über Recyclarr garantiert die Einhaltung globaler Qualitätsstandards und macht das Setup nach einer Neuinstallation sofort konsistent.
