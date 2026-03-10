---
title: "Service: SABnzbd Downloader (Aviation-Grade)"
category: "services"
tags: [media, usenet, sabnzbd, downloader, dendritic]
id: "NIXH-40-MED-015"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["40-media/service-media-sabnzbd.nix"]
---

# Service: SABnzbd (Usenet Downloader)

## 1. User Layer (KISS)
SABnzbd ist dein Hochleistungs-Downloader für das Usenet. Er lädt Inhalte mit maximaler Geschwindigkeit, entpackt sie automatisch und bereitet sie für Sonarr/Radarr vor. Die Sicherheit wird durch mTLS und SSO am Dashboard garantiert.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Performance
* **Backend:** Natives NixOS-Modul mit automatischer Par2/Unrar Abhängigkeitsverwaltung.
* **Config:** Steuerung der sabnzbd.ini via SAB_CONFIG_FILE Umgebungsvariable.
* **Storage:** Direkter Schreibzugriff auf den Download-Pool.

### SRE Hardening
* **Sandbox:** ProtectSystem = "strict" und PrivateTmp aktiv.
* **Isolation:** Läuft in einem dedizierten Network Namespace (netns) zur VPN-Erzwingung.

## 3. Reasoning Layer (History)

### [ADR-059] Native SABnzbd vs. Docker
Die native Installation auf NixOS ermöglicht eine effizientere Nutzung der CPU beim Entpacken (Par2) und vermeidet den Overhead von Container-Netzwerken bei Multi-Gigabit-Downloads.
