---
title: "Architectural Audit: mynixos vs. nixarr & nixflix"
category: "learnings"
tags: [audit, nixos, nixarr, nixflix, security, best-practices]
date: 2026-03-08
source: "claude-chat-3ac2b8a2"
status: "verified-substance-definitive"
---

# 🧠 LEARNING: REPO-AUDIT & COMMUNITY COMPARISON

Dieses Dokument analysiert die mynixos-Architektur im Vergleich zu den Community-Standards `nixarr` und `nixflix`.

---

## 🏗️ 1. USER LAYER: DIE BILANZ (KISS)
Dein System ist konzeptionell **besser durchdacht** als nixflix und **schlanker** als nixarr.
- **Vorteil:** Du nutzt native NixOS-Features (VPN, Firewall) statt komplexer Dritt-Abstraktionen.
- **Fokus:** Deine Stärke ist die eingebaute Sicherheit ("Security Assertions"), die in den Referenz-Repos komplett fehlt.

---

## 🛠️ 2. TECHNICAL LAYER: DIE BUG-REPARATURLISTE

### 🔴 Kritische Korrekturen (Sofort fällig)
1. **Homepage-Assertion Bug:** Du prüfst in `90-policy` eine Option (`services.homepage-dashboard.openFirewall`), die du gar nicht nutzt, da du Homepage als eigenen systemd-Service baust.
   - *Fix:* Entweder auf das offizielle NixOS-Modul umsteigen oder die Assertion auf dein Custom-Modul anpassen.
2. **Import-Lücke `de-config.nix`:** Die Datei mit NTP-Servern und DNS-over-TLS wird aktuell ignoriert.
   - *Fix:* In `configuration.nix` importieren.
3. **Fragiles Port-Handling in `_lib.nix`:** Deine Media-Services nutzen Default-Ports. Wenn du sie in `my.ports` änderst, hat das aktuell keine Auswirkung auf den Dienst.
   - *Fix:* `portOption` Parameter in der Service-Factory ergänzen.

### 🟡 Architektur-Feinheiten
- **SABnzbd Hardcode:** Die festen UIDs/GIDs (194/984) sollten in eine zentrale `my.ids` Registry überführt werden, um Konflikte bei Neuinstallationen zu vermeiden.
- **Valkey:** Der Dienst läuft "leer". Verdrahtung mit Paperless-ngx (Task-Queue) fehlt.

---

## 📜 3. REASONING LAYER: HERLEITUNG & STRATEGIE

### Warum dein VPN-Ansatz überlegen ist?
`nixarr` und `nixflix` nutzen oft externe Docker-Container oder Mullvad-Daemons. Dein Ansatz via `wg-quick` (native) in Kombination mit `RestrictNetworkInterfaces` ist kernel-nah und bietet einen echten, ausbruchssicheren Killswitch ohne Overhead.

### Warum `_lib.nix` der richtige Weg ist?
Du vermeidest die 150-Zeilen-Boilerplate von nixarr. Deine Abstraktion ist wartungsfreundlich, muss aber wie oben erwähnt um die explizite Port-Konfiguration erweitert werden, um die SSoT (Single Source of Truth) Integrität zu wahren.

---

## ✅ SERVICE-BACKLOG (ERWEITERUNGS-POTENZIAL)
- [ ] **Recyclarr:** Zur automatisierten TRaSH-Guide Synchronisation.
- [ ] **Lidarr:** Einfache Integration via `_lib.nix` möglich.
- [ ] **Bazarr:** Erfordert Custom-Systemd-Unit (kein nativer Service).
