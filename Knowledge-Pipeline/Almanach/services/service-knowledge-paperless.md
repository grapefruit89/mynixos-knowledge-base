---
title: "Service: Paperless-ngx (Aviation-Grade Knowledge Archive)"
category: "services"
tags: [knowledge, paperless, ocr, dendritic]
id: "NIXH-50-KNW-003"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["50-knowledge/service-app-paperless.nix"]
---

# Service: Paperless-ngx (Digital Archive)

## 1. User Layer (KISS)
Paperless-ngx ist dein papierloses Büro. Es erkennt Text in deinen Scans automatisch und macht alles durchsuchbar. Deine Dokumente sind sicher auf deinem Server gespeichert und durch dein privates SSO geschützt.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Pfade
* **Backend:** PostgreSQL und Redis/Valkey für hohe Performance.
* **OCR:** Automatisiert via Tesseract.
* **State:** Zentrales State-Management unter /data/state/.

### SRE Hardening
* **Netzwerk:** Zugriff ausschließlich via Caddy + Pocket-ID SSO.
* **Namespace:** Kann isoliert im netns betrieben werden.

## 3. Reasoning Layer (History)

### [ADR-056] Native Module vs. Docker-Bundle
Die Nutzung des nativen NixOS-Moduls spart Ressourcen und bietet eine sauberere Integration in den globalen PostgreSQL-Cluster.
