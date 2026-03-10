# GEMINI.md – Das Manifest (Definitive Edition)
# Stand: März 2026 | Supersedes: alle Vorgänger-Versionen

---

## 0. OBERSTES GEBOT: PFAD-REINHEIT

- Schreiben NUR in `/home/Knowledge-Pipeline/` und `/home/mynixos/`
- `/root/` ist absolute Verbotszone – kein Schreiben, keine temporären Dateien
- `/tmp/` nur Read-Only für `git clone` zur Wissensextraktion
- Kein `cat << EOF` (Syntaxfehler-Risiko) – ausschließlich `printf` Zeile für Zeile
- Nach jeder Operation: Reinheits-Check auf `/root/`

---

## I. PROJEKT-ZIEL

Migration von Unraid/Docker zu einem nativen NixOS-Homeserver (Fujitsu Q958).

**Ziel-Stack:** Medien (ARR + Jellyfin), Kommunikation (Conduit), 
Produktivität (Vaultwarden, n8n, Paperless), Identity (Pocket-ID).

**Nicht-Ziele:** Kein Unraid, kein Docker, kein Podman, kein Traefik, 
kein iptables, kein Denix (zu bleeding-edge).

---

## II. UNVERÄNDERLICHE PRINZIPIEN

### Software-Selektion (Prioritäts-Reihenfolge)
1. Natives NixOS-Modul (`services.X.enable`) – absolute Priorität
2. Nixpkgs-Paket + eigener systemd-Unit
3. Externer Flake-Input (community-geprüft, battle-tested)
4. ❌ Docker/Podman/OCI – grundsätzlich verboten

### Binary-Effizienz-Mandat
Go/Rust/C Single-Binaries gewinnen gegen Python/Java-Stacks 
wenn funktionaler Ersatz existiert.
Beispiele: Caddy > Nginx, Valkey > Redis, Conduit > Synapse

### No-Legacy-Mandat
- Proxy: **Caddy** (nicht Traefik)
- Firewall: **nftables** (nicht iptables)
- Boot: **systemd-boot + UEFI** (nicht GRUB)
- Pakete: **Flakes only** (keine Channels)

### Modularität: Dendritic-Pattern
`flake-parts` + `import-tree` – eine Datei = ein Feature.
NixOS + Home-Manager Konfiguration eines Dienstes leben in einer Datei.
Kein `denix` (experimentell), kein `specialArgs`-Tunnel.

---

## III. LAYER-ARCHITEKTUR (modules/)

| Layer | Kriterium | Beispiele |
|---|---|---|
| `00-core` | OS ohne dies: unsicher oder kaputt | SSH, Users, Firewall, Boot, Secrets |
| `20-server` | Server ohne dies: nicht erreichbar | Caddy, AdGuard, Tailscale, PostgreSQL, Valkey |
| `30-services` | Täglich genutzt, betriebskritisch | Vaultwarden, n8n, Home-Assistant, Matrix |
| `40-media` | Audio/Video-Konsum | Jellyfin, ARR-Stack, SABnzbd, Audiobookshelf |
| `50-knowledge` | Wissen & Dokumente | Paperless, Miniflux, Readeck, Linkding |
| `80-monitoring` | Beobachtet das System | Netdata, Scrutiny |
| `90-policy` | Regeln & Assertions | Build-Checks, Port-Kollisions-Guard |

---

## IV. WISSENSBASIS-STANDARD

### Pfade
- Rohdaten (Read-Only): `/home/Knowledge-Pipeline/raw/`
- Veredelte Docs (SSoT): `/home/Knowledge-Pipeline/docs/`
- Archiv/Superseded: `/home/Knowledge-Pipeline/raw/_duplikate/`
- NixOS-Code: `/home/mynixos/`

### Drei-Layer-Pflicht pro Dokument
1. **User Layer (KISS):** Oma-Logik – was macht das, wofür brauche ich es?
2. **Technical Layer:** Vollständige Spezifikation, Nix-Code, Parameter
3. **Reasoning Layer:** ADR – warum diese Entscheidung, was wurde verworfen?

### Sieben Qualitäts-Tore (Aviation-Grade Purity)
Jede `.nix`-Datei ist erst "veredelt" wenn sie alle 7 Tore passiert hat:
1. Community-Goldstandard (nixpkgs/modules Abgleich)
2. API-Accuracy (context7 Verifikation – nie halluzinieren)
3. SSoT-Compliance (Bindung an `configs.nix` und `ports.nix`)
4. SRE-Hardening (systemd-Isolation, Ziel: `systemd-analyze security` < 4.0)
5. Dendritische Integrität (One Service, One File, keine Zirkelbezüge)
6. Hygiene & Purity (kein toter Code, keine Metadaten als Nix-Options)
7. Traceability (YAML-Header mit Quellen-Referenz)

### Wissens-Wachstum (Löschverbot)
Neue Erkenntnisse ergänzen – sie ersetzen nie. Markierungen:
- `> [CONTEXT7-ENRICHMENT]:` – aus Context7
- `> [SEARCH-ENRICHMENT]:` – aus Web-Recherche  
- `> [ARCHITECT-NOTE]:` – interne logische Herleitung
- `> [SUPERSEDED]:` – überholt, bleibt aber im Reasoning Layer

---

## V. ANTI-HALLUZINATIONS-GESETZ

- Bei Nix-Optionen und API-Fragen: **IMMER zuerst `context7` befragen**
- Beweispflicht: Erfolg = physischer Check (`ls -la`, `head/tail`)
- Keine Platzhalter: `...` oder "Inhalt wie oben" = Systemverstoß
- Keine manuellen Systemeingriffe: kein `sed -i` auf Systemdateien,
  kein `pkill`, keine SSH/systemd-Manipulation ohne expliziten Auftrag

---

## VI. VERBOTENE PRAKTIKEN

- ❌ Metadaten als Nix-Options (`options.my.meta.*`) – gehört in Kommentar-Header
- ❌ `cat << EOF` – ersetzt durch `printf`
- ❌ Schreiben in `/root/`
- ❌ Docker/Podman/OCI-Container
- ❌ Traefik, iptables, GRUB, klassische Channels
- ❌ Denix-Framework

---

## VII. MCP-SERVER & TOOLING

Beim Start zu validieren:
- `context7` – Primäre Docs-Quelle (KRITISCH)
- `nixos` – Nix-Optionen Validierung
- `open-websearch` – Live Best-Practices
- `github` – Referenz-Repository Scans

Bei Ausfall: SOFORT melden. Kein stilles Scheitern.

---

## VIII. GIT-SYNC PROTOKOLL

- Repo: `https://github.com/grapefruit89/mynixos-knowledge-base.git`
- Pfad: `/home/Knowledge-Pipeline/docs/` → Branch `main`
- Trigger: Nach jeder erfolgreichen Veredelung
- Commit-Prefix: `adr:`, `services:`, `learnings:`, `guides:`
- Tokens: Nur via Umgebungsvariablen – niemals im Klartext
