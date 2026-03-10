# [SERVICE-MANIFEST]: Die unumstößliche Inventur (NixOS Native)
# ID: [MANIFEST-SRV-001] | Status: ACTIVE | Stand: 10.03.2026

## 1. Context (User Layer)
Wir beenden das "Verlieren" von Programmen. Dies ist die einzige Quelle der Wahrheit (SSoT) für alle Dienste, die auf dem Fujitsu Q958 laufen sollen. Wenn ein Dienst hier steht, wird er nicht ohne ADR gelöscht.

## 2. Der "Grüne" Stack (Native Module ✅)
Diese Dienste haben offizielle NixOS-Module und sind "Aviation-Grade".

- **Infrastruktur:** Caddy (Go), AdGuardHome (Go), Tailscale (Go), Cloudflared (Go), Pocket-ID (Go, Paket).
- **Datenbanken:** PostgreSQL, Valkey (C).
- **Medien:** Jellyfin, Sonarr, Radarr, Lidarr, Prowlarr, SABnzbd (Python, kein Ersatz), Recyclarr.
- **Wissen:** Paperless-ngx, Miniflux (Go), Linkding (Python, kein Ersatz).
- **Produktivität:** Vaultwarden (Rust), n8n, Home-Assistant.
- **Kommunikation:** Matrix Conduit (Rust).

## 3. Der "Gelbe" Stack (Grenzfälle 🟡)
Hier haben wir Kompromisse gemacht, die wir aber akzeptieren:
- **Audiobookshelf:** JS-Stack, aber Nixpkgs-Paket vorhanden.
- **Readeck:** Go-Binary, kein offizielles Modul, aber Paket.
- **Homepage:** Go-Binary, natives Modul vorhanden.
- **Semaphore:** Go-Binary (Ansible-Automation).

## 4. Die "Rote" Verbannung (RAUS 🔴)
Diese Dienste verstoßen gegen das Manifest (Docker-only, PHP-Stack, kein Paket):
- Traefik, Redis, Readarr-fork, Agent-Zero, Library-manager, OpenClaw, Audiobookrequest, Speedtest-tracker.

## 5. Offene Fragen (Warteschlange)
- **Lücke:** Audiobook-Request Tool (Kein Tool erfüllt das Manifest).
