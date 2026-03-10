# NixOS Homeserver – Master Briefing
**Stand: Februar 2026 | Fujitsu Q958 | Moritz Baumeister**

---

## 1. Hardware & System

| Komponente | Detail |
|---|---|
| Maschine | Fujitsu Q958 |
| CPU | Intel Core i3-9100 |
| RAM | 16 GB |
| iGPU | Intel UHD 630 – QuickSync H.264/H.265/HEVC |
| System-SSD | Micron/Crucial SATA SSD (~512 GB) – `/dev/sda` |
| Identifier | `ata-MTFDDAK512TDL-1AW1ZABFA_19432490DAF2` |
| HDDs | Noch nicht angeschlossen – kommen später |
| Hostname | `q958` |
| Benutzer | `moritz` |
| IP (aktuell DHCP) | 192.168.2.73 |
| SSH-Port | 22 |
| Betriebssystem | NixOS 25.11 (Unstable) mit XFCE (temporär) |

---

## 2. Aktueller Zustand des Repos

**GitHub:** `https://github.com/grapefruit89/mynixos`

Bereits vorhanden:
```
mynixos/
├── flake.nix
├── flake.lock
├── .sops.yaml
├── secrets.sops.yaml
├── .gitignore
├── README.md
├── hosts/
└── modules/
```

Die Grundstruktur steht. Inhalt der Module muss noch befüllt werden.

---

## 3. Finalisierte Ordnerstruktur (Ziel)

```
mynixos/
├── flake.nix
├── flake.lock
├── .sops.yaml
├── secrets.sops.yaml
├── .gitignore
│
├── hosts/
│   ├── q958/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── common/
│       └── core/
│           ├── default.nix
│           ├── users.nix
│           ├── ssh.nix
│           └── firewall.nix
│
└── modules/
    ├── 00-system/
    │   ├── nix-settings.nix
    │   └── storage.nix
    ├── 10-infrastructure/
    │   ├── traefik.nix
    │   ├── tailscale.nix
    │   ├── pocket-id.nix
    │   ├── valkey.nix
    │   ├── wireguard-vpn.nix
    │   ├── adguardhome.nix
    │   └── clamav.nix
    ├── 20-backend-media/
    │   ├── sabnzbd.nix
    │   ├── prowlarr.nix
    │   ├── sonarr.nix
    │   ├── radarr.nix
    │   ├── readarr.nix
    │   ├── lidarr.nix
    │   └── recyclarr.nix
    ├── 30-frontend-media/
    │   ├── jellyfin.nix
    │   ├── jellyseerr.nix
    │   └── audiobookshelf.nix
    └── 40-services/
        ├── vaultwarden.nix
        ├── paperless.nix
        ├── homepage.nix
        ├── miniflux.nix
        ├── linkding.nix
        ├── readeck.nix
        ├── home-assistant.nix
        ├── couchdb.nix
        ├── n8n.nix
        ├── semaphore.nix
        ├── uptime-kuma.nix
        ├── netdata.nix
        ├── scrutiny.nix
        └── immich.nix
```

---

## 4. Aktuelle configuration.nix (funktionierende Basis)

```nix
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "q958";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };

  # Desktop – temporär, wird später entfernt
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.xkb = { layout = "de"; variant = ""; };
  console.keyMap = "de";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  users.users.moritz = {
    isNormalUser = true;
    description  = "Moritz Baumeister";
    extraGroups  = [ "networkmanager" "wheel" "video" "render" ];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true;
  };
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vscodium git htop wget curl tree unzip file nix-output-monitor
  ];

  programs.firefox.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin        = "no";
      PasswordAuthentication = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
  services.printing.enable = false;

  # NIEMALS ändern!
  system.stateVersion = "25.11";
}
```

---

## 5. Verifizierde Pakete in nixpkgs (Stand Februar 2026)

Alle folgenden Services sind als native NixOS-Module verfügbar:

| Service | Version | NixOS-Modul |
|---|---|---|
| sonarr | 4.0.16.2944 | `services.sonarr.enable` |
| radarr | 6.0.4.10291 | `services.radarr.enable` |
| prowlarr | 2.3.0.5236 | `services.prowlarr.enable` |
| lidarr | 3.1.0.4875 | `services.lidarr.enable` |
| readarr | 0.4.18.2805 | `services.readarr.enable` |
| sabnzbd | 4.5.5 | `services.sabnzbd.enable` |
| recyclarr | 7.4.1 | `services.recyclarr.enable` |
| jellyfin | 10.11.6 | `services.jellyfin.enable` |
| jellyseerr | 2.7.3 | `services.jellyseerr.enable` |
| audiobookshelf | 2.32.1 | `services.audiobookshelf.enable` |
| vaultwarden | 1.35.3 | `services.vaultwarden.enable` |
| paperless-ngx | 2.20.6 | `services.paperless.enable` |
| miniflux | 2.2.17 | `services.miniflux.enable` |
| traefik | 3.6.7 | `services.traefik.enable` |
| tailscale | 1.94.2 | `services.tailscale.enable` |
| adguardhome | 0.107.71 | `services.adguardhome.enable` |
| netdata | 2.8.5 | `services.netdata.enable` |
| scrutiny | 0.8.1 | `services.scrutiny.enable` |
| n8n | 2.6.4 | `services.n8n.enable` |
| home-assistant | 2026.2.2 | `services.home-assistant.enable` |
| couchdb3 | 3.5.1 | `services.couchdb.enable` |

**Nicht in nixpkgs – brauchen custom systemd-Service:**
- linkding
- readeck
- semaphore
- pocket-id
- uptime-kuma
- immich

---

## 6. Architektur-Entscheidungen (endgültig)

### Storage
- **ext4** auf allen Partitionen – kein bcachefs, kein ZFS, kein mergerfs
- **Direkte HDD-Mountpoints** – mergerfs weckt alle HDDs bei jedem `readdir()` auf (durch ironicbadger FAQ bestätigt)
- **hd-idle** für Spindown nach 600 Sekunden
- **Atomic Move** via `.staging/` Ordner auf jeder HDD – Rename muss auf gleicher HDD stattfinden

### Authentifizierung
- **Pocket ID** als OIDC-Provider (~20 MB RAM, Go-Binary, Passkeys)
- **Traefik ForwardAuth** Middleware für Services ohne nativen OIDC-Support
- **Vaultwarden ohne SSO** – bewusst isoliert, eigener Login

### Reverse Proxy
- **Traefik v3** – natives NixOS-Modul, Let's Encrypt via DNS-Challenge (Cloudflare)

### Secrets
- **sops-nix** + Age-Keys – verschlüsselt in Git

### VPN
- **Maroka-chan/VPN-Confinement** – Network Namespace Killswitch für SABnzbd
- **AirVPN** – statisches Port-Forwarding, wg-quick kompatibel

### Jellyfin / Intel QuickSync
```nix
hardware.opengl.enable = true;
hardware.opengl.extraPackages = with pkgs; [
  intel-media-driver
  vaapiIntel
  intel-compute-runtime
];
users.users.jellyfin.extraGroups = [ "video" "render" ];
```

### Datenbank / Cache
- **Valkey** statt Redis – Redis hat seit 2024 BSL-Lizenz, Valkey ist BSD-3 und 100% kompatibel

### Abgelehnte Alternativen

| Was | Warum abgelehnt |
|---|---|
| mergerfs | Weckt alle HDDs auf |
| bcachefs | Zu jung, kein Vorteil bei 1.3 TB |
| ZFS | Special vdev zu teuer |
| SnapRAID | Medien wiederbeschaffbar, kein RAID nötig |
| Docker | 20+ native NixOS-Module verfügbar |
| FreshRSS | nginx-Lock-in im NixOS-Modul |
| Redis | BSL-Lizenz |
| Authelia | Overkill für 1–5 Nutzer |
| Keycloak | Enterprise-Overhead |
| Kubernetes | Überdimensioniert für Single-Host |
| nixarr/nixflix Module | Zu wenig Kontrolle – nur als Referenz |

---

## 7. Service-Tiers (Zugriffskonzept)

| Tier | Zugang | Services |
|---|---|---|
| 0 – Intern only | Tailscale | Homepage, Semaphore, Netdata, Scrutiny, Uptime Kuma, AdGuard, n8n, Radicale |
| 1 – LAN/Tailscale | Tailscale + LAN | Prowlarr, Sonarr, Radarr, Readarr, SABnzbd (VPN), Jellyseerr, Lidarr, Recyclarr |
| 2 – Internet | Pocket ID OIDC | Jellyfin, Audiobookshelf, Miniflux, Paperless-ngx, Linkding, Readeck, Immich |
| 3 – Eigener Login | Isoliert | Vaultwarden, Pocket ID, CouchDB, Home Assistant |

---

## 8. Referenz-Repositories

| Repo | Zweck |
|---|---|
| [EmergentMind/nix-config](https://github.com/EmergentMind/nix-config) | Hauptvorbild – hosts/common/core Pattern |
| [ironicbadger/nix-config](https://github.com/ironicbadger/nix-config) | Medienserver Best Practices |
| [ironicbadger/pms-wiki](https://github.com/ironicbadger/pms-wiki) | Perfect Media Server Dokumentation |
| [Maroka-chan/VPN-Confinement](https://github.com/Maroka-chan/VPN-Confinement) | VPN Killswitch für SABnzbd |
| [Mic92/sops-nix](https://github.com/Mic92/sops-nix) | Secrets Management |
| [nix-community/disko](https://github.com/nix-community/disko) | Deklarative Partitionierung |
| [serokell/deploy-rs](https://github.com/serokell/deploy-rs) | Remote Deployment vom Laptop |

---

## 9. Wichtige Befehle

```bash
# System rebuilden (im nix-config Verzeichnis)
sudo nixos-rebuild switch --flake .#q958

# Flake updaten
nix flake update

# Disk IDs anzeigen (für disko.nix)
ls -la /dev/disk/by-id/

# Nix Store aufräumen
sudo nix store gc --delete-older-than 7d

# Paket suchen
nix search nixpkgs <paketname>

# SSH vom Laptop
ssh moritz@192.168.2.73

# Auf Q958: aktuelle Konfiguration anzeigen
cat /etc/nixos/configuration.nix
```

---

## 10. Offene Aufgaben (nächste Schritte)

- [ ] Ordnerstruktur in `mynixos` vollständig anlegen
- [ ] `flake.nix` auf neue Modulstruktur umstellen
- [ ] `hosts/q958/default.nix` befüllen
- [ ] `hosts/common/core/` befüllen (users, ssh, firewall)
- [ ] sops-nix einrichten (Age-Key generieren, `.sops.yaml` konfigurieren)
- [ ] Statische IP für Q958 konfigurieren
- [ ] Tailscale aktivieren und registrieren
- [ ] Traefik + Let's Encrypt (Cloudflare DNS-Challenge)
- [ ] Pocket ID als custom systemd-Service
- [ ] ARR-Stack deployen (Prowlarr → SABnzbd → Sonarr/Radarr/Readarr)
- [ ] Jellyfin mit QuickSync
- [ ] HDDs anschließen und `disko.nix` ergänzen
- [ ] XFCE entfernen wenn alles stabil läuft

---

## 11. Backup-Strategie

| Was | Wohin | Tool |
|---|---|---|
| `/var/lib/` | Externe USB-HDD | Restic |
| `/etc/nixos` bzw. `mynixos/` | GitHub (privat) | Git |
| `secrets.sops.yaml` | Git (verschlüsselt via sops) | sops-nix |
| `/storage/hddX/` | Kein Backup – Medien wiederbeschaffbar | – |
| Jellyfin Metadata | Kein Backup – wird neu gescannt | – |

---

*Dieses Dokument als erstes in jeden neuen Chat hochladen.*
*Repo: https://github.com/grapefruit89/mynixos*
