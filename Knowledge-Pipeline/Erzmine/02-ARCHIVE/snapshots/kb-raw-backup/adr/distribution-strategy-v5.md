---
title: "NixOS Distribution Strategy: The Opinionated Starter"
category: "adr"
tags: [nixos, architecture, distribution, self-hosting]
date: 2026-03-08
source: "architect-vision-v5"
status: "verified-substance"
---

# 🚀 [ADR-INFO]: VOM CONFIG-REPO ZUR SELBSTHOSTING-DISTRIBUTION

## Status: Akzeptiert
## Kontext
Das Ziel ist ein "Zero-to-Hero" Erlebnis für Self-Hoster. Ein Nutzer soll ohne tiefes Nix-Wissen einen gehärteten Server in Minuten in Betrieb nehmen können.

## Entscheidung: Das "Single-Entry-Point" Prinzip
Wir kapseln die Komplexität der Dendritic-Module (Layer 00-90) vollständig ab. Der Nutzer interagiert nur mit zwei Dateien:
1. `USER_CONFIG.nix` (Funktionale Logik: "Was soll laufen?")
2. `secrets.sops.yaml` (Sensible Daten: "Wie lauten die Keys?")

### Der Deployment-Workflow
1. **Clone:** `git clone https://github.com/grapefruit89/mynixos`
2. **Configure:** Ausfüllen der `USER_CONFIG.nix` und `secrets.sops.yaml`.
3. **Deploy:** `nixos-anywhere --flake .#default <IP>`

> [LIVE-ENRICHMENT]: Die Integration von **nixos-anywhere** in Kombination mit **disko** (deklarative Partitionierung) ermöglicht die vollständige Automatisierung von einer leeren Festplatte bis zum fertig konfigurierten Caddy-Proxy inkl. TLS.

## 🧠 SRE-VORTEILE
- **Reproduzierbarkeit:** Jeder Server der Distribution folgt dem identischen Sicherheits-Standard ("M1 Abrams").
- **Wartbarkeit:** Updates am Kern-System (Modules) können via Upstream-Merge eingespielt werden, ohne die `USER_CONFIG.nix` zu gefährden.
