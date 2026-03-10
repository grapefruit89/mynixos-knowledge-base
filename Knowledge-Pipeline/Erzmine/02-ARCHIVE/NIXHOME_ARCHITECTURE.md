# 🛰️ NIXHOME — SEMANTISCHE LAYER-ARCHITEKTUR (FINAL)

Stand: 2026-03-02

---

## DIE KERNFRAGE PRO LAYER

Bevor eine Datei irgendwo landet, stelle diese eine Frage:

| Layer | Frage |
|---|---|
| `00-core` | Ist das OS ohne dieses Modul **unsicher oder kaputt**? |
| `20-server` | Ist der Server ohne dieses Modul **von außen nicht erreichbar oder intern nicht funktional**? |
| `30-services` | Ist das ein Service den ich **täglich nutze** und der mir fehlt wenn er weg ist? |
| `40-media` | Hat das mit **Audio- oder Video-Konsum** zu tun? |
| `50-knowledge` | Speichert oder verarbeitet das **persönliches Wissen oder Dokumente**? |
| `80-monitoring` | **Beobachtet** das den Zustand des Systems oder seiner Dienste? |
| `90-policy` | Definiert das **Regeln, Grenzen oder Enforcement**? |

---

## 00-core — Das Fundament

**Kriterium:** Das OS ist ohne dieses Modul unsicher, startet nicht, oder ist nicht zu administrieren.

```
00-core/
├── configs.nix                ⭐ SSoT Master (identity, hardware, paths, network)
├── defaults.nix               ⭐ SSoT Defaults (alle Module referenzieren das)
├── ports.nix                  ⭐ Zentrales Port-Register (10k/20k Schema)
├── registry.nix               Feature-Flags (enable/disable Profile)
├── lib-helpers.nix            mkService() Helper — technisch notwendig
│
├── hardware-configuration.nix          nixos-generate-config
├── host-q958-hardware-configuration.nix
├── host-q958-hardware-profile.nix      Intel UHD 630, Q958-spezifisch
├── host.nix                            hostname
│
├── kernel-slim.nix            Blacklists, sysctl hardening
├── system.nix                 systemd-boot, configurationLimit, git-hooks
├── system-stability.nix       EFI cleanup, drift detection
├── boot-safeguard.nix         /boot overflow Schutz + GC
├── zram-swap.nix              Compressed RAM swap
│
├── users.nix                  Declarative user management, GID 169
├── secrets.nix                SOPS Age-Key, Templates
├── ssh.nix                    Hardened SSHD, Post-Quantum Crypto
├── ssh-rescue.nix             5min Recovery Window nach Boot
├── firewall.nix               nftables, Zonen, LAN/Tailscale Regeln
├── fail2ban.nix               Brute-Force Protection (gehört zur OS-Sicherheit)
│
├── network.nix                systemd-networkd, BBR, mDNS
├── locale.nix                 Zeitzone, Tastatur, NTP
├── logging.nix                journald volatile tuning
├── nix-tuning.nix             Binary-Only Policy, GC, Sandbox
│
├── storage.nix                mergerfs ABC-Tiering, Pool-Definition
├── backup.nix                 Restic daily + rclone cloud sync
└── symbiosis.nix              CPU microcode auto-detect, RAM warnings
```

**Bewusst NICHT in 00-core:**
- Shell-Aliases, Fastfetch, MOTD → das ist Komfort, kein OS
- Caddy, AdGuard → der Server läuft und ist sicher ohne die
- AI-Tools → offensichtlich kein OS-Bestandteil

---

## 20-server — Server-Plumbing

**Kriterium:** Ohne dieses Modul ist der Server von außen nicht erreichbar
oder intern nicht funktional betreibbar.

```
20-server/
├── caddy.nix                  Edge Proxy, TLS, Geoblock, SSO-Snippets
├── adguardhome.nix            DNS-Filter + lokaler Resolver (alle anderen brauchen DNS)
├── tailscale.nix              Zero-Touch VPN (Remote-Zugriff)
├── cloudflared-tunnel.nix     Cloudflare Ingress
│
├── pocket-id.nix              OIDC Identity Provider
├── sso.nix                    SSO Bootstrap + Redirect-Whitelist
│
├── postgresql.nix             Datenbank-Cluster (miniflux, paperless, n8n)
├── valkey.nix                 Redis-Fork (Cache für paperless, sessions)
│
├── vpn-confinement.nix        WireGuard Network Namespace
├── vpn-live-config.nix        VPN Credentials (auto-generated via secret-ingest)
├── secret-ingest.nix          VPN .conf Landing Zone → Nix-Konvertierung
├── dns-map.nix                Subdomain-Registry (pure data, kein systemd)
├── dns-automation.nix         Cloudflare DNS Guard (Konflikt-Check)
├── ddns-updater.nix           Dynamic DNS
│
├── clamav.nix                 Antivirus (Server-Sicherheit, nicht OS-Kern)
└── landing-zone-ui.nix        Rescue HTML für LAN-Direktzugriff
```

**Warum PostgreSQL in 20-server und nicht woanders?**
PostgreSQL ist Infrastruktur — ein leerer DB-Cluster ohne Services.
Miniflux *benutzt* PostgreSQL, aber PostgreSQL gehört nicht zu Miniflux.
Genau wie in nixpkgs: `services/databases/` ist von `services/web-apps/` getrennt.

---

## 30-services — Täglich genutzte Server-Services

**Kriterium:** Ein Service den ich jeden Tag brauche und dessen Ausfall mich sofort stört.
Nicht OS-kritisch, aber betriebskritisch für den Alltag.

```
30-services/
├── vaultwarden.nix            Passwort-Manager (täglich, kritisch für Alltag)
├── homepage.nix               Dashboard (Navigation zu allem)
├── n8n.nix                    Workflow Automation
├── home-assistant.nix         Smart Home Zentrale
├── zigbee-stack.nix           Mosquitto + Zigbee2MQTT (MQTT Broker)
├── matrix.nix                 Self-hosted Chat
├── filebrowser.nix            Web-Dateimanager
├── olivetin.nix               Web-Aktionen Panel (Rebuild-Buttons etc.)
├── cockpit.nix                Admin WebUI
│
├── ollama.nix                 Lokale LLM Inferenz
├── open-webui.nix             LLM Web-Interface
├── ai-tools.nix               aider-chat, inshellisense, blesh
│
├── shell.nix                  Shell-Aliases, eza/bat/ripgrep
├── shell-premium.nix          Fastfetch MOTD, erweiterte Git-Aliases
├── motd.nix                   Login Banner (Firewall-Status, IP)
├── tty-info.nix               TTY1 IP-Anzeige nach Boot
├── home-manager.nix           User-Environment Management
├── user-moritz-home.nix       Persönliche User-Config (htop, micro, bat)
├── automation.nix             sudo-Regeln für nixos-rebuild
└── auto-locale.nix            IP-basierte Locale-Erkennung
```

---

## 40-media — Audio & Video Konsum

**Kriterium:** Hat mit Medienkonsum zu tun — Filme, Serien, Musik, Hörbücher, Podcasts.

```
40-media/
├── media-stack.nix            Layout-Enforcement, GID 169, tmpfiles, Gruppen
├── media-stack-enable.nix     Enable-Flags (welche arr-Apps aktiv sind)
├── _lib.nix                   mkMediaService Helper (interner Helper)
├── _servarr-factory.nix       Servarr Settings-Options Factory
│
├── jellyfin.nix               Media Server (Hardware-Transcoding QSV/iHD)
├── jellyseerr.nix             Media Request Management
├── sonarr.nix                 TV Serien Downloader
├── radarr.nix                 Film Downloader
├── lidarr.nix                 Musik Downloader
├── readarr.nix                E-Book Downloader
├── prowlarr.nix               Indexer Manager
├── sabnzbd.nix                Usenet Download Client
├── audiobookshelf.nix         Hörbuch & Podcast Server
├── recyclarr.nix              Quality Profile Manager (Radarr/Sonarr)
└── arr-wire.nix               API-Key Auto-Wiring zwischen arr-Apps
```

---

## 50-knowledge — Wissen & persönliches Gedächtnis

**Kriterium:** Speichert, verarbeitet oder erschließt persönliches Wissen,
Dokumente, Fotos oder soziale Informationen.

```
50-knowledge/
├── paperless.nix              Dokument-Management (OCR, Archiv)
├── monica.nix                 Personal CRM (Kontakte, Beziehungen, Notizen)
├── miniflux.nix               RSS Feed Reader (Wissenseingang)
├── readeck.nix                Read-Later / Web-Archiv
├── karakeep.nix               Bookmark Manager
└── stirling-pdf.nix           PDF Werkzeugkasten
```

**Warum Monica hier?**
Monica ist ein persönliches Wissenssystem für Beziehungen — konzeptuell
identisch zu Paperless (persönliche Daten strukturiert ablegen).

**Was noch fehlen könnte:**
- Immich (Foto-Management) → würde hier landen
- Obsidian Sync Backend (z.B. LiveSync) → hier
- Nextcloud (falls gewünscht) → hier

---

## 80-monitoring — Beobachtung & Analyse

**Kriterium:** Beobachtet passiv den Zustand — produziert selbst keinen Mehrwert,
zeigt nur an was andere tun.

```
80-monitoring/
├── netdata.nix                Echtzeit System-Metriken (CPU, RAM, Disk, Net)
├── scrutiny.nix               HDD/SSD SMART-Daten Überwachung
└── uptime-kuma.nix            Service-Erreichbarkeits-Monitoring
```

**Die Unterscheidung zu 30-services:**
n8n produziert Mehrwert (führt Workflows aus) → 30-services.
Uptime-Kuma beobachtet nur ob n8n läuft → 80-monitoring.

---

## 90-policy — Regeln & Enforcement

**Kriterium:** Definiert was erlaubt ist, prüft Strukturregeln, keine Services.

```
90-policy/
├── flat-layout.nix            Zero-Depth Struktur-Enforcement (Build bricht ab)
├── ssot-assertions.nix        Globale NixOS Assertions (Port-Kollisionen etc.)
└── nms-integrity.nix          NMS-ID Eindeutigkeit, Checksum-Prüfung
```

---

## VOLLSTÄNDIGES MIGRATIONS-MAPPING

### Aus 00-core raus

| Datei | Ziel | Grund |
|---|---|---|
| `00-core/ai-tools.nix` | `30-services/ai-tools.nix` | Komfort-Tool, kein OS |
| `00-core/auto-locale.nix` | `30-services/auto-locale.nix` | Optionales Feature |
| `00-core/home-manager.nix` | `30-services/home-manager.nix` | User-Komfort |
| `00-core/user-moritz-home.nix` | `30-services/user-moritz-home.nix` | User-Komfort |
| `00-core/user-preferences.nix` | `30-services/` oder löschen | Leer |
| `00-core/motd.nix` | `30-services/motd.nix` | Komfort |
| `00-core/shell.nix` | `30-services/shell.nix` | Komfort |
| `00-core/shell-premium.nix` | `30-services/shell-premium.nix` | Komfort |
| `00-core/tty-info.nix` | `30-services/tty-info.nix` | Komfort |
| `00-core/central-configs-plan.nix` | Löschen | Leer/dokumentativ |
| `00-core/principles.nix` | Löschen | Leer/dokumentativ |

### Aus 10-infrastructure raus (kompletter Layer wird umbenannt)

| Datei | Ziel | Grund |
|---|---|---|
| `10-infrastructure/caddy.nix` | `20-server/caddy.nix` | |
| `10-infrastructure/adguardhome.nix` | `20-server/adguardhome.nix` | |
| `10-infrastructure/tailscale.nix` | `20-server/tailscale.nix` | |
| `10-infrastructure/cloudflared-tunnel.nix` | `20-server/cloudflared-tunnel.nix` | |
| `10-infrastructure/pocket-id.nix` | `20-server/pocket-id.nix` | |
| `10-infrastructure/sso.nix` | `20-server/sso.nix` | |
| `10-infrastructure/postgresql.nix` | `20-server/postgresql.nix` | |
| `10-infrastructure/valkey.nix` | `20-server/valkey.nix` | |
| `10-infrastructure/vpn-confinement.nix` | `20-server/vpn-confinement.nix` | |
| `10-infrastructure/vpn-live-config.nix` | `20-server/vpn-live-config.nix` | |
| `10-infrastructure/secret-ingest.nix` | `20-server/secret-ingest.nix` | |
| `10-infrastructure/dns-map.nix` | `20-server/dns-map.nix` | |
| `10-infrastructure/dns-automation.nix` | `20-server/dns-automation.nix` | |
| `10-infrastructure/ddns-updater.nix` | `20-server/ddns-updater.nix` | |
| `10-infrastructure/clamav.nix` | `20-server/clamav.nix` | |
| `10-infrastructure/landing-zone-ui.nix` | `20-server/landing-zone-ui.nix` | |
| `10-infrastructure/homepage.nix` | `30-services/homepage.nix` | täglich genutzt |
| `10-infrastructure/cockpit.nix` | `30-services/cockpit.nix` | täglich genutzt |
| `10-infrastructure/uptime-kuma.nix` | `80-monitoring/uptime-kuma.nix` | reine Beobachtung |

### Aus 20-automation raus (Layer wird zu 30-services)

| Datei | Ziel | Umbenennung |
|---|---|---|
| `20-automation/automation.nix` | `30-services/automation.nix` | |
| `20-automation/service-app-ai-agents.nix` | `30-services/ollama.nix` | Prefix weg |
| `20-automation/service-app-home-assistant.nix` | `30-services/home-assistant.nix` | Prefix weg |
| `20-automation/service-app-n8n.nix` | `30-services/n8n.nix` | Prefix weg |
| `20-automation/service-app-olivetin.nix` | `30-services/olivetin.nix` | Prefix weg |
| `20-automation/service-app-open-webui.nix` | `30-services/open-webui.nix` | Prefix weg |
| `20-automation/service-app-zigbee-stack.nix` | `30-services/zigbee-stack.nix` | Prefix weg |
| `20-automation/service-app-karakeep.nix` | `50-knowledge/karakeep.nix` | Prefix weg + Layer |
| `20-automation/service-app-semaphore.nix` | Löschen | Leer |

### 30-media → 40-media (Layer-Nummer ändert sich)

| Datei | Ziel | Umbenennung |
|---|---|---|
| `30-media/media-stack.nix` | `40-media/media-stack.nix` | |
| `30-media/service-media-_lib.nix` | `40-media/_lib.nix` | Prefix weg |
| `30-media/service-media-_servarr-factory.nix` | `40-media/_servarr-factory.nix` | Prefix weg |
| `30-media/service-media-arr-wire.nix` | `40-media/arr-wire.nix` | Prefix weg |
| `30-media/service-app-audiobookshelf.nix` | `40-media/audiobookshelf.nix` | Prefix weg |
| `30-media/service-media-default.nix` | `40-media/_imports.nix` | Umbenannt |
| `30-media/service-media-jellyfin.nix` | `40-media/jellyfin.nix` | Prefix weg |
| `30-media/service-media-jellyseerr.nix` | `40-media/jellyseerr.nix` | Prefix weg |
| `30-media/service-media-lidarr.nix` | `40-media/lidarr.nix` | Prefix weg |
| `30-media/service-media-media-stack.nix` | `40-media/media-stack-enable.nix` | Umbenannt |
| `30-media/service-media-prowlarr.nix` | `40-media/prowlarr.nix` | Prefix weg |
| `30-media/service-media-radarr.nix` | `40-media/radarr.nix` | Prefix weg |
| `30-media/service-media-readarr.nix` | `40-media/readarr.nix` | Prefix weg |
| `30-media/service-media-recyclarr.nix` | `40-media/recyclarr.nix` | Prefix weg |
| `30-media/service-media-sabnzbd.nix` | `40-media/sabnzbd.nix` | Prefix weg |
| `30-media/service-media-services-common.nix` | `40-media/_common.nix` | Umbenannt |
| `30-media/service-media-sonarr.nix` | `40-media/sonarr.nix` | Prefix weg |

---

## NOCH FEHLENDE MODULE

Aus ports.nix abgeleitet — registriert aber kein .nix vorhanden:

```
50-knowledge/
├── paperless.nix      → PORT 20981 (fehlt!)
├── miniflux.nix       → PORT 20008 (fehlt!)
├── readeck.nix        → PORT 20005 (fehlt!)
└── monica.nix         → PORT 20004 (fehlt!)

30-services/
├── vaultwarden.nix    → PORT 20002 (fehlt!)
├── matrix.nix         → PORT 20006 (fehlt!)
└── filebrowser.nix    → PORT 20001 (fehlt!)

80-monitoring/
├── netdata.nix        → PORT 10999 (fehlt!)
└── scrutiny.nix       → PORT 20007 (fehlt!)
```

---

## NIXPKGS-PARALLELE

| nixpkgs `/nixos/modules/` | NixHome Layer |
|---|---|
| `system/boot/` | `00-core/` (system.nix, kernel-slim.nix) |
| `security/` | `00-core/` (firewall, ssh, fail2ban) |
| `services/networking/` | `20-server/` (caddy, adguard, tailscale) |
| `services/databases/` | `20-server/` (postgresql, valkey) |
| `services/misc/` | `30-services/` (n8n, vaultwarden, home-assistant) |
| `services/web-apps/` | `30-services/` + `50-knowledge/` |
| `services/misc/` (arr) | `40-media/` |
| `services/monitoring/` | `80-monitoring/` |

Der Unterschied: nixpkgs trennt Module von Packages.
Wir kombinieren beides — jede .nix-Datei ist Modul UND Konfiguration zugleich.

---

## ENDSTRUKTUR

```
/etc/nixos/
│
├── 00-core/         ~25 Dateien — OS ist sicher und startet
├── 20-server/       ~16 Dateien — Server ist erreichbar
├── 30-services/     ~21 Dateien — Alltag funktioniert
├── 40-media/        ~17 Dateien — Unterhaltung läuft
├── 50-knowledge/    ~ 6 Dateien — Wissen ist zugänglich
├── 80-monitoring/   ~ 3 Dateien — Alles wird beobachtet
└── 90-policy/       ~ 3 Dateien — Regeln werden durchgesetzt
```

**Gesamt: ~91 Dateien, 0 Unterordner, klare Semantik.**
