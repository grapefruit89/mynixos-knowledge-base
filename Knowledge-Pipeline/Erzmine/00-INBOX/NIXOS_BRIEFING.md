# NixOS Homeserver – Briefing Dokument
**Für neuen Chat-Start | Stand: Februar 2026**

---

## 1. Wer bin ich & was habe ich

**Benutzer:** Moritz | **Laptop:** Nobara Linux (User: moritz)
**Server:** Fujitsu Q958 | i3-9100 | 16GB RAM | Intel UHD 630 (QuickSync H.264/H.265)

### Storage
| Gerät | Größe | Zweck |
|---|---|---|
| Samsung NVMe | ~477 GB | OS + `/var/lib` (alle Appdata) |
| Apacer NVMe | ~250 GB | `/downloads` (Download-Cache) |
| Seagate HDD | 298 GB | `/storage/hdd1` (Filme) |
| Hitachi HDD | 500 GB | `/storage/hdd2` (Serien) |
| WD HDD | 500 GB | `/storage/hdd3` (Bücher/Hörbücher) |

### Aktueller Stand
- NixOS installiert mit XFCE (temporär)
- Hostname: `q958` | User: `moritz`
- Git & VSCodium installiert
- SSH aktiv auf Port 22
- Repo `~/nix-config` angelegt, gepusht nach: `https://github.com/grapefruit89/gemini-home`
- Flakes aktiviert in `nix.settings.experimental-features`

---

## 2. Referenz-Repositories (Vorbilder)

| Repo | Warum relevant |
|---|---|
| [EmergentMind/nix-config](https://github.com/EmergentMind/nix-config) | **Hauptvorbild** – hosts/common/core Pattern, sops-nix, disko |
| [ironicbadger/nix-config](https://github.com/ironicbadger/nix-config) | Medienserver Best Practices, Homelab-Erfahrung |
| [ironicbadger/nix-install-kickoff](https://github.com/ironicbadger/nix-install-kickoff) | Remote NixOS Installation via SSH |
| [ironicbadger/pms-wiki](https://github.com/ironicbadger/pms-wiki) | Perfect Media Server Dokumentation |
| [Maroka-chan/VPN-Confinement](https://github.com/Maroka-chan/VPN-Confinement) | VPN-Killswitch für SABnzbd (Network Namespace) |
| [rasmus-kirk/nixarr](https://github.com/rasmus-kirk/nixarr) | Nur als Referenz/Inspiration – nicht direkt importieren |
| [Mic92/sops-nix](https://github.com/Mic92/sops-nix) | Secrets Management |
| [nix-community/disko](https://github.com/nix-community/disko) | Deklarative Partitionierung |
| [serokell/deploy-rs](https://github.com/serokell/deploy-rs) | Remote Deployment vom Laptop |

---

## 3. Finalisierte Ordnerstruktur

```
nix-config/
├── flake.nix
├── flake.lock
├── .sops.yaml
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

## 4. Kern-Architektur-Entscheidungen (FINAL – nicht nochmal diskutieren)

### Storage
- **ext4** auf allen Partitionen (kein bcachefs, kein ZFS, kein mergerfs)
- **Direkte HDD-Mountpoints** – mergerfs weckt alle HDDs bei jedem readdir() auf
- **hd-idle** für Spindown nach 600 Sekunden
- **Atomic Move** via `.staging/` Ordner auf jeder HDD (MUSS auf gleicher HDD liegen!)

### Authentifizierung / SSO
- **Pocket ID** als OIDC-Provider (Passkeys, ~20MB RAM, Go-Binary)
- **Traefik ForwardAuth** Middleware für Services ohne nativen OIDC-Support
- **Vaultwarden OHNE SSO** – bewusst isoliert, eigener Login

### Reverse Proxy
- **Traefik** (natives NixOS-Modul, Let's Encrypt via DNS-Challenge)

### Secrets
- **sops-nix** + Age-Keys – verschlüsselt in Git

### Partitionierung
- **disko** – deklarativ, reproduzierbar

### VPN
- **Maroka-chan/VPN-Confinement** – echter Network Namespace Killswitch für SABnzbd
- **AirVPN** empfohlen (statisches Port-Forwarding, wg-quick Support)

### Jellyfin / QuickSync
```nix
hardware.opengl.enable = true;
hardware.opengl.extraPackages = with pkgs; [
  intel-media-driver
  vaapiIntel
  intel-compute-runtime
];
users.users.jellyfin.extraGroups = [ "video" "render" ];
```

### Abgelehnte Alternativen (endgültig)
| Was | Warum abgelehnt |
|---|---|
| mergerfs | Weckt alle HDDs – bestätigt durch ironicbadger FAQ |
| bcachefs | Zu jung, kein Tiering-Vorteil bei 1.3TB |
| Docker | 20+ Services haben native NixOS-Module |
| FreshRSS | nginx-Lock-in im NixOS-Modul |
| Redis | BSL-Lizenz seit 2024 → Valkey stattdessen |
| Authelia | Overkill für 1-5 User → Pocket ID |
| nixarr/nixflix Module | Zu wenig Kontrolle – nur als Referenz |

---

## 5. Aktuelle configuration.nix (Basis)

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

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.xkb = { layout = "de"; variant = ""; };
  console.keyMap = "de";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.moritz = {
    isNormalUser = true;
    description = "Moritz Baumeister";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vscodium git htop wget curl tree unzip file nix-output-monitor
  ];

  programs.firefox.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
  services.printing.enable = false;

  system.stateVersion = "25.11";
}
```

---

## 6. Nächste Schritte (ToDo)

- [ ] **Ordnerstruktur anlegen** per Heredoc-Script auf dem Q958
- [ ] **flake.nix** auf neue Struktur umstellen (hosts/q958 als Modul)
- [ ] **sops-nix** einrichten (Age-Key generieren, .sops.yaml anlegen)
- [ ] **disko.nix** schreiben (HDD by-id Pfade ermitteln!)
- [ ] **Tailscale** aktivieren
- [ ] **Traefik** konfigurieren (Let's Encrypt DNS-Challenge via Cloudflare)
- [ ] **Pocket ID** als custom systemd-Service
- [ ] **ARR-Stack** deployen
- [ ] **Jellyfin** mit QuickSync
- [ ] XFCE entfernen wenn alles stabil läuft

---

## 7. Wichtige Befehle

```bash
# System rebuilden
sudo nixos-rebuild switch --flake .#q958

# Disk IDs anzeigen (für disko.nix)
ls -la /dev/disk/by-id/

# IP-Adresse anzeigen
ip addr show | grep "inet " | grep -v 127

# SSH vom Laptop
ssh moritz@192.168.2.73

# Nix Store aufräumen
sudo nix store gc --delete-older-than 7d
```

---

*Dieses Dokument als erstes in den neuen Chat hochladen – dann hat Claude sofort den vollen Kontext.*
