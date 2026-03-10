---
title: "Dashboard Strategy: Admin vs. Family"
category: "adr"
tags: [dashboard, glance, homer, homepage, nixos, user-experience]
date: 2026-03-08
source: "claude-cloudflare-log-b99bb6b3"
status: "verified-substance-definitive"
---

# 🏛️ [ADR-INFO]: DASHBOARD-STRATEGIE (HIERARCHISCHE TRENNUNG)

Dieses Dokument definiert die Wahl und Trennung der Web-Oberflächen für verschiedene Nutzergruppen.

---

## 🏗️ 1. USER LAYER: WER SIEHT WAS? (KISS)
- **Admin (Du):** Braucht volle Kontrolle, RSS-Feeds, Server-Stats und Arrr-Queues.
- **Familie:** Braucht nur drei Knöpfe: Filme, Serien, Hörbücher. Alles andere würde nur verwirren.

---

## 🛠️ 2. TECHNICAL LAYER: TOOL-AUSWAHL

### A. Admin Dashboard: Glance
- **Warum:** Einzelne Go-Binary, extrem leichtgewichtig (<20MB RAM).
- **Features:** Widgets für Sonarr/Radarr, RSS-Feeds, Wetter, Server-Stats.
- **NixOS-Integration:** Reine YAML-Konfiguration, perfekt deklarativ.

### B. Familien Dashboard: Homer
- **Warum:** Komplett statisch, null Overhead.
- **Features:** Nur Links zu Jellyfin, Audiobookshelf und Seerr.
- **Vorteil:** Keine Lernkurve, absolut stabil.

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum kein gemeinsames Homepage-Dashboard?
Homepage unterstützt keine native Multi-User-Ansicht (kein Login-System). Es müssten zwei separate Homepage-Instanzen laufen. Glance (für dich) bietet jedoch deutlich mehr "Information at a glance" (RSS, Queues), während Homer (für die Familie) die kognitive Last auf ein Minimum reduziert.

### Warum Glance statt Homarr?
Glance folgt der NixOS-Philosophie (Simple Binary + YAML). Homarr benötigt eine Datenbank und Node.js, was den Wartungsaufwand und den Ressourcenverbrauch unnötig erhöht.
