---
title: "Security Layer Model: 3-Stage Defense"
category: "adr"
tags: [security, cloudflare, waf, access, mtls, zero-trust]
date: 2026-03-08
source: "claude-cloudflare-log-b99bb6b3"
status: "verified-substance-definitive"
---

# 🏛️ [ADR-INFO]: DAS 3-SCHICHTEN DEFENSIV-MODELL

Dieses Dokument definiert die hierarchische Absicherung aller nach außen gerichteten Dienste der mynixos Distribution.

---

## 🏗️ 1. USER LAYER: DIE TÜRSTEHER-LOGIK (KISS)
Wir schützen den Server wie eine exklusive Veranstaltung:
1. **Der Zaun (Schicht 1):** Cloudflare blockt böse Länder und Bots.
2. **Der Ausweis-Check (Schicht 2):** Wer rein will, braucht einen digitalen Passkey (OIDC).
3. **Der VIP-Schlüssel (Schicht 3):** Für die Technik-Räume (Admin) reicht ein Passkey nicht aus – hier muss das Gerät selbst ein Zertifikat haben.

---

## 🛠️ 2. TECHNICAL LAYER: DIE DEFENSIV-KASKADE

### Schicht 1: Cloudflare Edge (WAF)
- **Modus:** Orange Cloud (Proxied).
- **Features:** WAF (Free Plan), Bot Fight Mode, Strict SSL/TLS (Full End-to-End).
- **Geoblocking:** Sperrung aller Regionen außer DACH (DE/AT/CH).

### Schicht 2: Cloudflare Access (Zero Trust)
- **Funktion:** Policy-basierter Zugriffsschutz.
- **Identity Provider (IdP):** Pocket-ID (via generic OIDC) oder One-Time PIN.
- **Workflow:** CF Access fängt die Anfrage ab -> Leitet zu Pocket-ID weiter -> Bei Erfolg Weiterleitung zum Traefik.

### Schicht 3: mTLS (Mutual TLS)
- **Einsatz:** Nur für Admin-Dienste und APIs (Gruppe 0/1).
- **Hardening:** Cloudflare prüft das Client-Zertifikat am Edge. Ohne gültiges Zertifikat erfolgt ein 403-Fehler, bevor die Anfrage überhaupt dein Heimnetz erreicht.

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum Orange vs. Gray Cloud?
- **Orange (Proxied):** Für App-Daten (Nextcloud, Vaultwarden). Schützt deine Heim-IP.
- **Gray (DNS-only):** Für High-Bandwidth Medien (Jellyfin). Cloudflare Proxy hat Limits bei der Dateigröße/Streaming im Free Plan. Hier liegt die IP offen, was durch WireGuard oder IP-Whitelisting in Traefik kompensiert wird.

### Warum mTLS nicht für die Familie?
mTLS ist wartungsintensiv (Zertifikats-Installation auf Endgeräten). Für Familienmitglieder ist ein Passkey (OIDC) über Pocket-ID der perfekte Kompromiss aus Sicherheit und Benutzerfreundlichkeit ("Oma-Logik").
