---
title: "NixHome Architecture (NMS v4.2)"
category: "adr"
tags: [nixos, architecture, modularity, layers]
date: 2026-03-08
source: "raw/chats/NIXHOME_ARCHITECTURE.md"
status: "verified-substance"
---

# 🏛️ [ADR-INFO]: NIXHOME — SEMANTISCHE LAYER-ARCHITEKTUR (FINAL)

Dieses Dokument definiert die Kern-Architektur des NixOS Homelabs (Fujitsu Q958) und dient als Einstiegspunkt für die System-Strukturierung.

> **Verwandte Konzepte:** 
> - [Sovereign Identity v4](sovereign-identity-v4.md)
> - [Identity Security Audit](identity-security-audit.md)

## 📋 DIE KERNFRAGE PRO LAYER

Bevor eine Datei in das System integriert wird, muss sie sich durch folgende Kriterien für einen Layer qualifizieren:

| Layer | Frage |
|---|---|
| `00-core` | Ist das OS ohne dieses Modul **unsicher oder kaputt**? |
| `20-server` | Ist der Server ohne dieses Modul **von außen nicht erreichbar oder intern nicht funktional**? |
| `30-services` | Ist das ein Service, den ich **täglich nutze** und der mir fehlt, wenn er weg ist? |
| `40-media` | Hat das mit **Audio- oder Video-Konsum** zu tun? |
| `50-knowledge` | Speichert oder verarbeitet das **persönliches Wissen oder Dokumente**? |
| `80-monitoring` | **Beobachtet** das den Zustand des Systems oder seiner Dienste? |
| `90-policy` | Definiert das **Regeln, Grenzen oder Enforcement**? |

> [LIVE-ENRICHMENT]: Die Nutzung einer strikten Layer-Architektur ist in großen NixOS-Projekten Best-Practice, um "Dependency Hell" zu vermeiden. Moderne Frameworks wie `flake-parts` oder `snowfall-lib` bieten hierfür built-in Mechanismen an, um Module automatisch nach Ordnerstruktur zu evaluieren.

## 🏗️ 00-core — Das Fundament

**Kriterium:** Das OS ist ohne dieses Modul unsicher, startet nicht, oder ist nicht zu administrieren.

```bash
00-core/
├── configs.nix                # SSoT Master (identity, hardware, paths, network)
├── defaults.nix               # SSoT Defaults (alle Module referenzieren das)
├── ports.nix                  # Zentrales Port-Register (10k/20k Schema)
├── registry.nix               # Feature-Flags (enable/disable Profile)
├── lib-helpers.nix            # mkService() Helper — technisch notwendig
│
├── hardware-configuration.nix          
├── host-q958-hardware-configuration.nix
├── host-q958-hardware-profile.nix      # Intel UHD 630, Q958-spezifisch
├── host.nix                            # hostname
│
├── kernel-slim.nix            # Blacklists, sysctl hardening
├── system.nix                 # systemd-boot, configurationLimit, git-hooks
├── system-stability.nix       # EFI cleanup, drift detection
├── boot-safeguard.nix         # /boot overflow Schutz + GC
├── zram-swap.nix              # Compressed RAM swap
│
├── users.nix                  # Declarative user management, GID 169
├── secrets.nix                # SOPS Age-Key, Templates
├── ssh.nix                    # Hardened SSHD, Post-Quantum Crypto
├── ssh-rescue.nix             # 5min Recovery Window nach Boot
├── firewall.nix               # nftables, Zonen, LAN/Tailscale Regeln
├── fail2ban.nix               # Brute-Force Protection (gehört zur OS-Sicherheit)
│
├── network.nix                # systemd-networkd, BBR, mDNS
├── locale.nix                 # Zeitzone, Tastatur, NTP
├── logging.nix                # journald volatile tuning
├── nix-tuning.nix             # Binary-Only Policy, GC, Sandbox
│
├── storage.nix                # mergerfs ABC-Tiering, Pool-Definition
├── backup.nix                 # Restic daily + rclone cloud sync
└── symbiosis.nix              # CPU microcode auto-detect, RAM warnings
```

**Bewusst NICHT in 00-core:**
- Shell-Aliases, Fastfetch, MOTD → das ist Komfort, kein OS.
- Caddy, AdGuard → der Server läuft und ist sicher ohne diese Dienste.
- AI-Tools → kein natives OS-Bestandteil.

## 🌐 20-server — Server-Plumbing

**Kriterium:** Ohne dieses Modul ist der Server von außen nicht erreichbar oder intern nicht funktional betreibbar.

```bash
20-server/
├── caddy.nix                  # Edge Proxy, TLS, Geoblock, SSO-Snippets
├── adguardhome.nix            # DNS-Filter + lokaler Resolver
├── tailscale.nix              # Zero-Touch VPN (Remote-Zugriff)
├── cloudflared-tunnel.nix     # Cloudflare Ingress
│
├── pocket-id.nix              # OIDC Identity Provider
├── sso.nix                    # SSO Bootstrap + Redirect-Whitelist
│
├── postgresql.nix             # Datenbank-Cluster (miniflux, paperless, n8n)
├── valkey.nix                 # Redis-Fork (Cache für paperless, sessions)
│
├── vpn-confinement.nix        # WireGuard Network Namespace
├── vpn-live-config.nix        # VPN Credentials
├── secret-ingest.nix          # VPN .conf Landing Zone → Nix-Konvertierung
├── dns-map.nix                # Subdomain-Registry (pure data)
├── dns-automation.nix         # Cloudflare DNS Guard (Konflikt-Check)
├── ddns-updater.nix           # Dynamic DNS
│
├── clamav.nix                 # Antivirus (Server-Sicherheit)
└── landing-zone-ui.nix        # Rescue HTML für LAN-Direktzugriff
```
> [ARCHITECT-NOTE]: PostgreSQL liegt korrekt in `20-server`, da es fundamentale Infrastruktur für abhängige Web-Apps bildet.

## 🛠️ 30-services — Täglich genutzte Server-Services

**Kriterium:** Ein Service, der täglich benötigt wird (betriebskritisch für den Alltag, aber nicht OS-kritisch).

```bash
30-services/
├── vaultwarden.nix            # Passwort-Manager
├── homepage.nix               # Dashboard
├── n8n.nix                    # Workflow Automation
├── home-assistant.nix         # Smart Home Zentrale
├── zigbee-stack.nix           # Mosquitto + Zigbee2MQTT
├── matrix.nix                 # Self-hosted Chat
├── filebrowser.nix            # Web-Dateimanager
├── olivetin.nix               # Web-Aktionen Panel
├── cockpit.nix                # Admin WebUI
│
├── ollama.nix                 # Lokale LLM Inferenz
├── open-webui.nix             # LLM Web-Interface
├── ai-tools.nix               # aider-chat, inshellisense, blesh
│
├── shell.nix                  # Shell-Aliases, eza/bat/ripgrep
├── shell-premium.nix          # Fastfetch MOTD
├── motd.nix                   # Login Banner
├── tty-info.nix               # TTY1 IP-Anzeige nach Boot
├── home-manager.nix           # User-Environment Management
├── user-moritz-home.nix       # Pers. Config
├── automation.nix             # sudo-Regeln für nixos-rebuild
└── auto-locale.nix            # IP-basierte Locale-Erkennung
```

## 🍿 40-media — Audio & Video Konsum

**Kriterium:** Medienkonsum (Filme, Serien, Musik, Hörbücher).

```bash
40-media/
├── media-stack.nix            # Layout-Enforcement, GID 169
├── media-stack-enable.nix     # Enable-Flags
├── _lib.nix                   # mkMediaService Helper
├── _servarr-factory.nix       # Servarr Settings-Options Factory
│
├── jellyfin.nix               # Media Server (Hardware-Transcoding)
├── jellyseerr.nix             # Media Request Management
├── sonarr.nix                 # TV Serien
├── radarr.nix                 # Filme
├── lidarr.nix                 # Musik
├── readarr.nix                # E-Books
├── prowlarr.nix               # Indexer Manager
├── sabnzbd.nix                # Usenet Client
├── audiobookshelf.nix         # Hörbücher & Podcasts
├── recyclarr.nix              # Quality Profile Manager
└── arr-wire.nix               # API-Key Auto-Wiring
```

## 🧠 50-knowledge — Wissen & persönliches Gedächtnis

**Kriterium:** Speichert, verarbeitet oder erschließt persönliches Wissen.

```bash
50-knowledge/
├── paperless.nix              # Dokument-Management
├── monica.nix                 # Personal CRM
├── miniflux.nix               # RSS Feed Reader
├── readeck.nix                # Read-Later
├── karakeep.nix               # Bookmark Manager
└── stirling-pdf.nix           # PDF Werkzeugkasten
```

---
