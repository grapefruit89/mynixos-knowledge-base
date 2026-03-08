---
title: "Software Purism: Declarative & Native Selection"
category: "adr"
tags: [nixos, architecture, declarative, vanilla]
date: 2026-03-08
source: "repo-audit:mynixos"
status: "verified-substance"
---

# 🏛️ [ADR-INFO]: DEKLARATIVER PURISMUS & SOFTWARE-SELEKTION

## Status: Akzeptiert
## Kontext
Um die Distribution wartbar und "Aviation-Grade" zu halten, müssen wir Redundanzen vermeiden und Programme wählen, die sich zu 100% deklarativ in NixOS integrieren lassen.

## ⚖️ DIE GOLDENEN REGELN DER SELEKTION
1. **NixOS Native > OCI-Containers:** Wenn ein Programm ein offizielles Modul in `nixpkgs` hat, nutzen wir es. (Beispiel: `services.jellyfin` statt Docker-Jellyfin).
2. **Deklarative Config > Web-UI Config:** Wir bevorzugen Programme, deren gesamte Logik in Textdateien definiert werden kann.
3. **One Tool, One Purpose:** Wir vermeiden Überschneidungen (z.B. nicht zwei Dashboards).

---

## 🛠️ DER "PURISTEN-STACK" (SELEKTION)

| Kategorie | Programm | Warum diese Wahl? (Purismus-Check) |
| :--- | :--- | :--- |
| **Firewall** | `nftables` | Vanilla NixOS-Integration, ersetzt das veraltete `iptables` vollständig. |
| **Reverse-Proxy** | `Caddy` | Native NixOS-Optionen für VirtualHosts, automatisches TLS via Cloudflare DNS-01. |
| **Dashboard** | `Homepage` | Komplett deklarativ via YAML/Nix steuerbar. Keine Datenbank nötig. |
| **DNS/Filter** | `AdGuardHome` | Bessere deklarative Steuerung der Filterregeln via Nix als Pi-Hole. |
| **Identity** | `Pocket-ID` | Modern, Passkey-fokussiert, lässt sich via Environment-Files perfekt härten. |
| **Media-Stack** | `nixarr/nixflix` Logik | Nutzt native Nix-Module für Sonarr/Radarr statt Container-Wildwuchs. |
| **Monitoring** | `Netdata` | Exzellentes NixOS-Modul für Echtzeit-Statistiken ohne komplexe InfluxDB-Stacks. |

---

## 🚨 ELIMINIERUNG VON REDUNDANZEN (REFAKTORIERUNGS-BEDARF)

Basierend auf dem Repo-Audit vom 08.03.2026:

### 1. Dashboard-Konsolidierung
- **Befund:** Im Repo finden sich Referenzen auf Homepage, Cockpit und potenziell andere UIs.
- **Entscheidung:** **Homepage** ist die primäre Nutzer-UI. **Cockpit** wird nur als Low-Level OS-Management Tool behalten (Layer 80).

### 2. Datenbank-Zentralisierung
- **Befund:** Viele Apps bringen eigene SQLite/Datenbank-Container mit.
- **Entscheidung:** Wir forcieren die Nutzung eines zentralen **PostgreSQL-Clusters** (Layer 20), da dieser über `services.postgresql` perfekt deklarativ gesichert und optimiert werden kann.

### 3. Container-Audit
- **Befund:** Apps wie `linkwarden` oder `readeck` laufen oft als Container.
- **Entscheidung:** Wir prüfen für jeden Dienst in Layer 50/60, ob ein natives Nix-Paket existiert, um den Docker-Overhead (und die impermanenten Volumes) zu reduzieren.

> [LIVE-ENRICHMENT]: Die Nutzung von `systemd-analyze security` auf nativen NixOS-Diensten liefert eine wesentlich präzisere Sicherheits-Metrik als das "Black-Box" Modell von Docker-Containern. Unser Ziel ist ein Score von < 3.0 für alle Kern-Services.
