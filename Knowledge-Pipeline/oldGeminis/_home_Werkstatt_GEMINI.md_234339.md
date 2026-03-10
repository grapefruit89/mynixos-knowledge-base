# GEMINI.md – Die Master-Verfassung (v12.0)
# Status: SOVEREIGN PORTABLE ARCHITECTURE | Stand: März 2026
# Supersedes: v11.0, v10.0, v7.0 → archiviert in /home/Knowledge-Pipeline/Erzmine/02-ARCHIVE/versions/
# ADR-040: LAW OF ASSOCIATIVE MINING – AKTIV

---

## PREAMBLE: WAS DIESE DATEI IST

Dies ist die einzige Quelle der Wahrheit (Single Source of Truth, SSoT) für den Betrieb des
KI-Agenten Gemini CLI auf dem "mynixos"-Homeserver-Framework. Sie ist KEIN README. Sie ist
ein operatives Grundgesetz. Jede Abweichung davon ist ein Systemfehler, keine Meinung.

**Lebenszyklus dieser Datei:**
- Diese Datei DARF NICHT manuell editiert werden, ohne einen ADR (Architecture Decision Record) zu erstellen.
- Ältere Versionen werden NICHT gelöscht. Sie werden in `/home/Knowledge-Pipeline/Erzmine/02-ARCHIVE/versions/` mit Versions-Suffix archiviert (z.B. `GEMINI_v11.0.md`).
- Wissen wird NIEMALS vernichtet. Veraltetes wird als `[DEPRECATED]` markiert und bleibt im Reasoning Layer erhalten.

---

## 0. OBERSTES GEBOT: DIE DREIFALTIGKEIT DER PFADE

```
WERKSTATT:   /home/Werkstatt/                           🟢 NixOS-Code (.nix only)
ALMANACH:    /home/Knowledge-Pipeline/Almanach/         🟢 Veredeltes Wissen & Gesetze
ERZMINE:     /home/Knowledge-Pipeline/Erzmine/          🟤 Rohdaten & Souveränitätsspeicher
PERSIST:     /persist/                                  🔴 Dauerhafter Zustand (Secrets, DBs)
```

### Das Schreib-Mandat (Path Purity – v7.0 Erbe, dauerhaft)

| Pfad       | Regel                                                        |
|------------|--------------------------------------------------------------|
| `/root/`   | **ABSOLUTE VERBOTSZONE.** Kein Schreiben, keine Temp-Dateien |
| `/tmp/`    | Nur Read-Only für `git clone`-Operationen                   |
| `/home/Werkstatt/` | Ausschließlich `.nix`-Dateien. Keine Skripte, kein Markdown |
| `/home/Knowledge-Pipeline/` | Alle Wissens-Artefakte, Logs, Dokumente       |

**Datei-Schreib-Methode:** Ausschließlich Python-Direkt-Write oder `tee`.
- VERBOTEN: `cat << EOF` (Syntaxfehler bei Sonderzeichen)
- VERBOTEN: `printf` mit Sonderzeichen (Flag-Interpretation)
- PFLICHT: Nach jeder Operation: `ls -la /root/` → Reinheits-Nachweis im Log

### Archiv-Struktur (Löschverbot)

```
/home/Knowledge-Pipeline/Erzmine/
├── 02-ARCHIVE/
│   ├── versions/
│   │   ├── GEMINI_v7.0.md      ← archiviert (Pfad-Reinheit-Ära)
│   │   ├── GEMINI_v10.0.md     ← archiviert (Hardware-Fixierungs-Ära)
│   │   └── GEMINI_v11.0.md     ← archiviert (Universal-Portability-Ära)
│   └── snapshots/
│       └── kb-raw-backup/      ← Unveränderliche Rohdaten
└── .vectorstore/               ← RAG-Index (LanceDB)
```

---

## I. PROJEKT-ZIEL & NICHT-ZIELE

### Das Ziel

Migration von Unraid/Docker/Traefik zu einem vollständig nativen, deklarativen NixOS-Homeserver.
Das System ist hardware-agnostisch (ISO-Standard) und muss auf jedem x86_64-Linux-System mit
korrekt gesetzten Disk-Labels lauffähig sein. Portabilität ist kein Feature, sondern eine
Verfassungspflicht.

### Ziel-Stack

```
Infrastruktur:  Caddy, AdGuardHome, Tailscale, Cloudflared
Identity:       Pocket-ID (OIDC + Passkeys)
Datenbanken:    PostgreSQL, Valkey            ← Redis: VERBOTEN (→ Valkey)
Medien:         Jellyfin, Sonarr, Radarr, Prowlarr, SABnzbd,
                Audiobookshelf, Jellyseerr, Recyclarr
Kommunikation:  Matrix Conduit
Produktivität:  Vaultwarden, n8n, Home Assistant, Paperless
Wissen:         Miniflux, Readeck, Linkding, Karakeep
Ops:            Homepage, Semaphore, OliveTin, ddns-updater
Monitoring:     Scrutiny, Netdata, Uptime-Kuma
```

### Permanente Nicht-Ziele (VERBOTEN, keine Ausnahmen)

| Kategorie   | Verbotene Technologie              | Erlaubter Ersatz         |
|-------------|------------------------------------|--------------------------|
| Container   | Docker, Podman, OCI                | systemd-nspawn (nativ)  |
| Proxy       | Traefik, Nginx                     | Caddy (Go)              |
| Firewall    | iptables                           | nftables                |
| Boot        | GRUB, klassische Channels          | systemd-boot + Flakes   |
| Cache/KV    | Redis                              | Valkey                  |
| Framework   | denix (experimentell)              | flake-parts + import-tree |
| Metadaten   | `options.my.meta.*` im Nix-System  | Externe YAML/JSON-DB    |
| Parser      | Text-Regex auf .nix-Dateien        | `nix eval --json`       |

**Begründung `options.my.meta.*` – KRITISCH (aus Architecture Review):**
> "Die Einbettung von Metadaten über `options.my.meta.*` bläht den Evaluierungsbaum des
> NixOS-Systems unnötig auf. Metadaten gehören nicht in die Laufzeit- oder Systemkonfiguration
> des Zielhosts. Die zentrale registry.nix wird bei über 100 Diensten zum Flaschenhals bei der
> Auswertung, da jede Änderung an den Metadaten einen kompletten Rebuild des System-Graphen
> triggern kann."
> — geminiverbesserung.txt (Erzmine, 2026-03-03)

---

## II. UNVERÄNDERLICHE PRINZIPIEN

### A. Software-Selektion (Prioritäts-Kaskade)

```
1. Natives NixOS-Modul (services.X.enable)   ← Absolute Priorität
2. Nixpkgs-Paket + eigener systemd-Unit
3. Community-Flake (battle-tested, >6 Monate stabil)
4. VERBOTEN: Docker/Podman/OCI
```

### B. Binary-Effizienz-Mandat

Go/Rust/C Single-Binaries gewinnen gegen Python/Java-Stacks, wenn ein funktionaler Ersatz
existiert. Dies ist keine Präferenz, sondern eine SRE-Entscheidung gegen Dependency-Inflation.

### C. No-Legacy-Mandat

| Funktion   | Legacy (VERBOTEN) | Moderne Alternative (PFLICHT) |
|------------|-------------------|-------------------------------|
| Proxy      | Traefik, Nginx    | Caddy (Go)                    |
| Firewall   | iptables          | nftables                      |
| Boot       | GRUB              | systemd-boot + UEFI           |
| Pakete     | Channels          | Flakes only                   |
| GPU        | generische Treiber| iHD (Intel QSV, QuickSync)    |
| IPC        | TCP auf localhost | Unix Domain Sockets (UDS)     |

### D. Modularitäts-Mandat (Dendritic-Pattern)

```
Werkzeuge:      flake-parts + import-tree (stabil, community-validated)
Regel:          Eine Datei = Ein Feature
                NixOS + Home-Manager eines Dienstes → eine Datei
Verboten:       specialArgs-Tunnel für Metadaten
Flake-Purity:   KEIN <path>-Import in Flake-Konfigurationen (NixPath = VERBOTEN)
                Korrektes Pattern: inputs.sops-nix.nixosModules.sops
```

### E. Flake-Purity-Gesetz (aus Bug-Review)

Flake-Konfigurationen MÜSSEN pure sein. Die Verwendung von `<sops-nix/modules/sops>` oder
jeglichem `<...>`-Pfad-Import ist in Flake-Kontexten ein Build-Fehler. Alle externen Module
werden ausschließlich über `inputs` referenziert:

```nix
# KORREKT:
imports = [ inputs.sops-nix.nixosModules.sops ];

# VERBOTEN (Flake-Purity-Verletzung):
imports = [ <sops-nix/modules/sops> ];
```

---

## III. ADR-040: DAS GESETZ DES ASSOZIATIVEN MININGS

Dies ist das Kerngesetz von v12.0. Es definiert, wie der KI-Agent zu denken hat.

### Das Prinzip: Seed & Satellite

Kein technischer Begriff ist eine Insel. Jeder Begriff (Seed) MUSS eine rekursive Suche nach
seinen technischen Abhängigkeiten (Satellites) auslösen. Das Versäumnis, das technische
Ökosystem eines Begriffs zu kartieren, ist ein Verstoß gegen diese Verfassung.

### Mining-Kaskaden (Definitiver Katalog)

#### Seed: `Storage` / `Festplatte` / `Disk`
```
Satellites (MANDATORY):
  → Disk-Label-Schema (DISK_SYSTEM, DISK_CACHE, DISK_STORAGE_*)
  → Filesystem-Typ pro Tier (ZFS / ext4 / passthrough)
  → MergerFS-Policy (category.create=epmfs PFLICHT)
  → MergerFS-Flags (func.getattr=newest, ignore_pp=true)
  → Mount-Reihenfolge (ZFS vor MergerFS, systemd.mounts ordering)
  → Atomic-Move-Kompatibilität (gleiche physische Platte für Staging)
  → FUSE-Permissions (allow_other, default_permissions)
  → Spindown-Logik (hdparm, sdparm oder udev-Regeln für SATA)
  → ZFS-ARC-Limit (vm.zfs.arc_max für RAM-Pressung)
  → Scrub-Schedule (systemd-Timer für wöchentlichen ZFS-Scrub)
  → /persist/-Layout (Welche Daten sind persistent, welche ephemer?)
```

#### Seed: `VPN` / `WireGuard` / `Privado`
```
Satellites (MANDATORY):
  → Kill-Switch-Mechanismus (Container mit privateNetwork=true)
  → Interface-Pass-through (nur WireGuard-Interface im Container sichtbar)
  → Leak-Protection (ohne aktives wg-Interface: KEIN Netzwerk-Escape möglich)
  → nftables-Regeln (DROP auf Output-Chain ohne VPN-Mark)
  → Container-Bridge-Isolation (kein Routing zum Host-Netz)
  → DNS-Leak-Prävention (systemd-resolved nur über VPN-Nameserver)
  → Reconnect-Strategie (systemd-networkd WireGuard-Persistent-Keepalive)
```

#### Seed: `Caddy` / `Reverse-Proxy` / `Ingress`
```
Satellites (MANDATORY):
  → Unix Domain Socket (UDS) statt TCP für Backend-Kommunikation
  → UDS-Pfad: /run/caddy/<service>.sock
  → Dateisystem-Permissions auf Socket (Caddy-User = Backend-User ODER Gruppe)
  → TLS-Terminierung (ACME via Let's Encrypt oder Cloudflare-DNS-Challenge)
  → HSTS-Header, CSP-Header (Security-Hardening)
  → systemd-Unit-Hardening: CapabilityBoundingSet=~, PrivateDevices=true,
    PrivateUsers=true, NoNewPrivileges=true, ProtectSystem=strict
  → Port-Kollisions-Guard (90-policy)
  → Upstream-Socket-Timeout-Konfiguration
```

#### Seed: `Pocket-ID` / `SSO` / `OIDC`
```
Satellites (MANDATORY):
  → UDS-Kommunikation zu Caddy (/run/caddy/pocket-id.sock)
  → Passkey-Only-Konfiguration (PASSWORD_AUTH_ENABLED=false)
  → PostgreSQL-Backend (services.postgresql, nicht SQLite für Produktion)
  → OIDC-Client-Registrierung pro Dienst (Vaultwarden, n8n, Jellyfin, etc.)
  → Session-Secret via sops-nix (NIEMALS im Klartext in .nix)
  → Backup-Strategie für OIDC-Clients (Restic nach /persist/ → Cloud)
```

#### Seed: `MergerFS` / `JBOD` / `Media-Pool`
```
Satellites (MANDATORY):
  → Policy: category.create=epmfs (ZWINGEND für Atomic Moves)
  → func.getattr=newest (korrekte Metadaten bei verteilten Dateien)
  → ignore_pp=true (Path-Preservation deaktivieren)
  → allow_other=true (für Jellyfin/Sonarr-Zugriff)
  → FUSE-Mount-Optionen: nonempty, lazy_umount
  → Inode-Konsistenz (alle Tier-C-Platten müssen gleiche GID 169 = media)
  → Staging-Pfad auf DISK_CACHE (SABnzbd → /mnt/DISK_CACHE/staging/)
  → Atomic-Move-Protokoll: mv /mnt/DISK_CACHE/staging/<file> /mnt/media/<dest>
    (zero-copy, da gleiche physische Disk via DISK_CACHE-Label)
  → Spindown-Koexistenz (FUSE-Idle-Timer vs. hdparm -S)
```

#### Seed: `Container` / `nspawn` / `Vault`
```
Satellites (MANDATORY):
  → privateNetwork=true (IMMER für exponierte Dienste)
  → Bridge-Interface (hardware-agnostisch, kein eth0/ens3 hartkodiert)
  → Kein physischer Bus-Bezug in App-Modulen (außer VPN-Interface)
  → BindMount für /persist/<service>/ (Zustandspersistenz)
  → systemd-nspawn machinectl enable <container> (Autostart)
  → Netzwerk-Namespace-Isolation verifizieren: ip netns list im Container
  → Nur exponierte Dienste in Containern: Jellyfin, Audiobookshelf, VPN-Satz
```

#### Seed: `ZFS` / `DISK_SYSTEM`
```
Satellites (MANDATORY):
  → Pool-Name: rpool (konventionell)
  → Dataset-Layout: rpool/local/nix, rpool/safe/home, rpool/safe/persist
  → Compression: lz4 (performance-optimal)
  → atime=off (keine Access-Time-Updates für Performance)
  → xattr=sa (schnelle Extended-Attributes für sops)
  → ARC-Max: vm.zfs.arc_max = <RAM/4> (in bytes, via boot.kernel.sysctl)
  → Scrub-Timer: systemd.services.zfs-scrub (wöchentlich)
  → Snapshot-Strategie: sanoid für automatische Snapshots
  → /persist/ ist ZFS-Dataset (rpool/safe/persist), NICHT tmpfs-Overlay
```

#### Seed: `SSH` / `Fernzugang`
```
Satellites (MANDATORY):
  → PermitRootLogin = "no"
  → PasswordAuthentication = "no"
  → PermitEmptyPasswords = "no"
  → MaxAuthTries = 3
  → AllowTcpForwarding = "no"
  → X11Forwarding = false
  → KexAlgorithms: sntrup761x25519-sha512@openssh.com (quantum-safe)
  → HostKey-Algorithmen: ssh-ed25519 only
  → MACs: hmac-sha2-512-etm@openssh.com
  → Fail2Ban oder sshguard (brute-force Schutz)
  → Authorized-Keys via sops-nix (nie im Klartext im Repo)
```

#### Seed: `Secrets` / `sops-nix` / `SOPS`
```
Satellites (MANDATORY):
  → sops-nix als Flake-Input: inputs.sops-nix.nixosModules.sops
  → .sops.yaml: age-Key im Repo, Host-SSH-Key als Entschlüsseler
  → Secrets-Pfade: /run/secrets/<name> (ephemer, RAM-backed)
  → NIEMALS Klartext-Secrets in .nix-Dateien
  → NIEMALS Secrets in flake.nix (kein impure-Pfad!)
  → Backup des age-Keys: /persist/secrets/age-key.txt (ZFS-gesichert)
  → Key-Rotation-Protokoll: sops updatekeys bei Hardware-Wechsel
```

---

## IV. STORAGE ARCHITECTURE: DAS DREISTUFIGE UNIVERSUM

Hardware-Slots sind `[DEPRECATED]`. Das System operiert ausschließlich auf Basis von
**Disk-Labels**. Jeder NixOS-Dienst, jeder Mount-Punkt und jeder Pfad referenziert Labels,
niemals physische Gerätenamen (`/dev/sda`, `/dev/nvme0n1`).

### A. Die Drei Tiers (Label-Standard)

```
┌──────────────────────────────────────────────────────────────┐
│ TIER A: DISK_SYSTEM                                          │
│   Filesystem: ZFS (rpool)                                    │
│   Inhalt:     NixOS-OS, /persist/, Secrets, DBs             │
│   Labeling:   Partition-Label auf ZFS-Vdev                   │
│   Beispiel:   Samsung NVMe M.2 (Q958: M.2 Main)             │
│   Portabilität: Beliebiges NVMe/SSD, korrekt gelabelt        │
├──────────────────────────────────────────────────────────────┤
│ TIER B: DISK_CACHE                                           │
│   Filesystem: ext4                                           │
│   Inhalt:     SABnzbd-Downloads, Transcoding-Cache, Staging  │
│   Labeling:   e2label /dev/<device> DISK_CACHE               │
│   Beispiel:   Apacer SSD M.2 (Q958: WLAN-Slot)              │
│   Portabilität: Beliebiges SSD/NVMe, korrekt gelabelt        │
├──────────────────────────────────────────────────────────────┤
│ TIER C: DISK_STORAGE_01, DISK_STORAGE_02, ...               │
│   Filesystem: ext4 (JBOD, kein RAID, kein Stripping)        │
│   Inhalt:     Bulk-Media (Jellyfin-Bibliothek), Archiv       │
│   Aggregation: MergerFS-Pool → /mnt/media                   │
│   Labeling:   e2label /dev/<device> DISK_STORAGE_01         │
│   Beispiel:   SATA-HDDs (Q958: SATA-Ports)                  │
│   Portabilität: Beliebige SATA/USB-HDDs, korrekt gelabelt    │
└──────────────────────────────────────────────────────────────┘
```

### B. Labeling-Prozedur (Hardware-Onboarding)

```bash
# Tier A: ZFS-Pool mit Label
zpool create -o ashift=12 rpool /dev/disk/by-id/<nvme-id>
zfs set org.freebsd:swap=0 rpool  # optional

# Tier B: ext4 mit Label
mkfs.ext4 -L DISK_CACHE /dev/sda
# oder nachträglich:
e2label /dev/sda DISK_CACHE

# Tier C: ext4 JBOD mit fortlaufendem Label
e2label /dev/sdb DISK_STORAGE_01
e2label /dev/sdc DISK_STORAGE_02
# ... fortsetzend für jede weitere HDD
```

### C. NixOS Mount-Konfiguration (ISO-Portable)

```nix
# fileSystems.nix – Ausschließlich Label-basiert, KEIN /dev/sdX
{ config, lib, ... }:
{
  fileSystems."/mnt/cache" = {
    device  = "/dev/disk/by-label/DISK_CACHE";
    fsType  = "ext4";
    options = [ "defaults" "noatime" "nofail" ];
  };

  fileSystems."/mnt/storage/01" = {
    device  = "/dev/disk/by-label/DISK_STORAGE_01";
    fsType  = "ext4";
    options = [ "defaults" "noatime" "nofail" ];
  };

  fileSystems."/mnt/storage/02" = {
    device  = "/dev/disk/by-label/DISK_STORAGE_02";
    fsType  = "ext4";
    options = [ "defaults" "noatime" "nofail" ];
  };
}
```

### D. MergerFS: Das Atomizitäts-Mandat

MergerFS aggregiert alle DISK_STORAGE_* zu einem einheitlichen `/mnt/media`-Pool.
Die Policy-Konfiguration ist NICHT verhandelbar.

```nix
# storage/mergerfs.nix
{ pkgs, config, ... }:
{
  # Satellite-Check (ADR-040 → VPN): Vor diesem Modul müssen alle DISK_STORAGE_*
  # gemountet sein (systemd.mounts-Abhängigkeit unten beachten)

  environment.systemPackages = [ pkgs.mergerfs ];

  fileSystems."/mnt/media" = {
    device  = "/mnt/storage/01:/mnt/storage/02";  # Erweiterbar: :/mnt/storage/03 etc.
    fsType  = "fuse.mergerfs";
    options = [
      "category.create=epmfs"     # PFLICHT: Atomic-Move-Kompatibilität
      "func.getattr=newest"       # PFLICHT: Korrekte Metadaten bei verteilten Files
      "ignore_pp=true"            # PFLICHT: Deaktiviert Path-Preservation-Overhead
      "allow_other=true"          # PFLICHT: Jellyfin/Sonarr-Zugriff (non-root)
      "use_ino=true"              # Konsistente Inode-Nummern
      "dropcacheonclose=true"     # Verhindert Inode-Cache-Korruption
      "nonempty"
      "lazy_umount"
      "nofail"
    ];
    depends = [
      "/mnt/storage/01"
      "/mnt/storage/02"
    ];
  };

  # Media-Gruppe für Jellyfin/Sonarr/Radarr/SABnzbd (GID 169 – Konvention aus legacy mynixos)
  users.groups.media = {
    gid     = 169;
    members = [ "jellyfin" "sonarr" "radarr" "sabnzbd" "prowlarr" ];
  };
}
```

### E. Das Atomic-Move-Protokoll (Zero-Copy)

Das Staging-Verzeichnis liegt IMMER auf DISK_CACHE. Moves von Staging → Media-Pool sind
zero-copy-fähig, weil DISK_CACHE physisch eine der DISK_STORAGE_*-Platten simuliert, sofern
die MergerFS-Policy `epmfs` korrekt arbeitet.

```
KORREKTE PIPELINE:
  1. SABnzbd Download   → /mnt/cache/staging/<file>       (DISK_CACHE)
  2. Post-Processing    → Umbenennen/Sortieren in /mnt/cache/staging/
  3. Atomic Move        → mv /mnt/cache/staging/<file> /mnt/media/Movies/
     (MergerFS epmfs wählt DISK_STORAGE mit meistem freiem Platz auf existierendem Pfad)
     (mv = rename() syscall wenn auf gleicher Platte → O(1), kein Datei-Copy)

VERBOTENE PIPELINE (nicht-atomisch, langsam):
  1. SABnzbd Download   → /tmp/<file>           (Tmpfs – ANDERE Platte!)
  2. Copy               → /mnt/media/Movies/     (Datei-Copy über Kernel-Buffer)
```

```nix
# SABnzbd-Konfiguration: Staging auf DISK_CACHE
services.sabnzbd = {
  enable = true;
  # In SABnzbd web UI: Temp Download Folder = /mnt/cache/staging/sabnzbd
  # Complete Download Folder = /mnt/cache/staging/complete
};
```

### F. No-RAID/No-Stripping-Mandat

```
VERBOTEN: mdadm, SnapRAID, ZFS-RAID, dm-stripe
BEGRÜNDUNG:
  1. Energie: RAID erfordert alle Platten gleichzeitig aktiv → kein Spindown
  2. Kapazität: RAID verbraucht 20-50% Nutzkapazität
  3. Sicherheit: RAID ≠ Backup. Ein Ransomware-Angriff löscht alle Mirror-Kopien.
  4. Souveränität: Daten-Redundanz erfolgt durch geografisch getrenntes Off-Site-Backup.

ERLAUBT:
  → Restic → Cloudflare R2 oder Backblaze B2 (verschlüsselt, off-site)
  → Sanoid-Snapshots (ZFS, lokal, schnelle Recovery)
  → Manuelle Kopie auf externe HDD (für physischen Notfall-Restore)
```

---

## V. SICHERHEITSARCHITEKTUR: DER UNIVERSELLE VAULT

### A. Das Container-Prinzip (nspawn)

NixOS-Container (systemd-nspawn) sind der "Nothammer" für drei Kategorien:
1. **Exponierte Dienste** (öffentlich erreichbar): Jellyfin, Audiobookshelf
2. **VPN-Confinement**: Dienste, die ausschließlich über VPN kommunizieren dürfen
3. **Privilege-Isolation**: Dienste, die Root-ähnliche Rechte benötigen

```nix
# containers/media-vault.nix
{ config, ... }:
{
  containers.media-vault = {
    # Satellite-Check (ADR-040 → VPN): privateNetwork erzwingt Kill-Switch
    privateNetwork = true;          # IMMER für exponierte Dienste – kein Kompromiss
    hostBridge     = "br-media";    # Hardware-agnostische Bridge (kein eth0)

    # VPN Kill-Switch: NUR das WireGuard-Interface wird reingegeben
    # Ohne aktives wg-privado: kein Netzwerk-Escape möglich
    interfaces     = [ "wg-privado" ];

    # Zustandspersistenz über /persist/
    bindMounts = {
      "/var/lib/jellyfin" = {
        hostPath   = "/persist/jellyfin";
        isReadOnly = false;
      };
    };

    config = { pkgs, ... }: {
      services.jellyfin.enable = true;
      # Hardware-Transcoding: Intel QuickSync via /dev/dri pass-through
      hardware.opengl.enable          = true;
      hardware.opengl.extraPackages   = [ pkgs.intel-media-driver ];
    };
  };

  # Bridge-Interface (hardware-agnostisch)
  networking.bridges."br-media".interfaces = [];
  networking.interfaces."br-media".ipv4.addresses = [{
    address      = "10.100.1.1";
    prefixLength = 24;
  }];
}
```

### B. Unix Domain Sockets (UDS) statt TCP – DAS LATERAL-MOVEMENT-GESETZ

**Ursprung:** Architecture Review (geminiverbesserung.txt, 2026-03-03)
> "Der Caddy-Reverse-Proxy kommuniziert über einen lokalen TCP-Port
> (localhost:${toString config.my.ports.pocketId}) mit dem SSO-Dienst. Dies eröffnet
> Angriffsvektoren für Lateral Movement innerhalb des Host-Netzwerks. Eine Kommunikation
> über Unix-Domain-Sockets ist hier zwingend erforderlich, um Zugriffsrechte auf
> Dateisystemebene strikt zu reglementieren."

**Das Gesetz:** Jede Kommunikation zwischen Caddy und einem Backend-Dienst auf demselben
Host MUSS über Unix Domain Sockets (UDS) erfolgen. TCP auf `localhost` ist VERBOTEN.

```nix
# proxy/caddy.nix – UDS-Konfiguration
{ config, pkgs, ... }:
{
  services.caddy = {
    enable         = true;
    virtualHosts = {

      # Pocket-ID via UDS (KORREKT)
      "id.${config.networking.domain}" = {
        extraConfig = ''
          reverse_proxy unix//run/caddy/pocket-id.sock
        '';
      };

      # Vaultwarden via UDS (KORREKT)
      "vault.${config.networking.domain}" = {
        extraConfig = ''
          reverse_proxy unix//run/caddy/vaultwarden.sock
        '';
      };
    };
  };

  # systemd-Hardening für Caddy (Satellite-Check ADR-040 → Caddy)
  systemd.services.caddy = {
    serviceConfig = {
      CapabilityBoundingSet = "~";           # Alle Capabilities entzogen
      PrivateDevices         = true;
      PrivateUsers           = true;
      NoNewPrivileges        = true;
      ProtectSystem          = "strict";
      ProtectHome            = true;
      ProtectKernelTunables  = true;
      RestrictAddressFamilies= [ "AF_UNIX" "AF_INET" "AF_INET6" ];
    };
  };
}
```

```nix
# services/pocket-id.nix – UDS-Socket-Aktivierung
{ config, pkgs, ... }:
{
  # Pocket-ID lauscht auf UDS, nicht auf TCP
  services.pocket-id = {
    enable = true;
    settings = {
      LISTEN_ADDR         = "unix:/run/caddy/pocket-id.sock";
      PASSWORD_AUTH_ENABLED = false;  # Passkey-Only (aus Erzmine-Review)
      DB_PROVIDER         = "postgres";
    };
    environmentFiles = [
      config.sops.secrets."pocket-id-env".path   # Kein Klartext!
    ];
  };

  # Sicherstellung: Socket-Verzeichnis mit korrekten Rechten
  systemd.tmpfiles.rules = [
    "d /run/caddy 0750 caddy caddy -"
  ];
}
```

### C. VPN Kill-Switch – Vollständige Implementierung

```nix
# network/vpn-confinement.nix
{ config, lib, pkgs, ... }:
{
  # WireGuard-Interface (Satellite-Check ADR-040 → VPN)
  networking.wireguard.interfaces."wg-privado" = {
    ips          = [ "10.x.x.x/32" ];    # Aus sops-secret
    privateKeyFile = config.sops.secrets."wg-privado-key".path;
    peers = [{
      publicKey           = "...";        # Aus sops-secret
      allowedIPs          = [ "0.0.0.0/0" ];
      endpoint            = "...";        # Aus sops-secret
      persistentKeepalive = 25;
    }];

    # Post-Up: erzwinge Traffic durch VPN-Tabelle
    postSetup = ''
      ip rule add not fwmark 0xca6c table 51820
      ip route add blackhole default metric 1 table 51820
    '';
    postShutdown = ''
      ip rule del not fwmark 0xca6c table 51820
      ip route del blackhole default metric 1 table 51820
    '';
  };

  # nftables Kill-Switch (Satellite-Check ADR-040 → VPN → nftables)
  networking.nftables.ruleset = ''
    table inet vpn-killswitch {
      chain output {
        type filter hook output priority 0; policy accept;

        # Erlaube Loopback
        oifname "lo" accept

        # Erlaube WireGuard-Handshake (UDP zu VPN-Server)
        udp dport 51820 accept

        # ALLES andere: nur über wg-privado erlaubt
        oifname "wg-privado" accept

        # Drop ohne VPN-Interface
        drop
      }
    }
  '';
}
```

### D. SSH-Hardening (CIS-Compliance)

```nix
# 00-core/ssh.nix – Aviation-Grade SSH
{ ... }:
{
  services.openssh = {
    enable         = true;
    ports          = [ 22 ];          # Ggf. ändern für Security-through-Obscurity
    settings = {
      PermitRootLogin          = "no";
      PasswordAuthentication   = false;
      PermitEmptyPasswords     = false;
      MaxAuthTries             = 3;
      AllowTcpForwarding       = false;
      X11Forwarding            = false;
      PrintMotd                = false;
      KexAlgorithms            = [ "sntrup761x25519-sha512@openssh.com" ];
      HostKeyAlgorithms        = [ "ssh-ed25519" ];
      Macs                     = [ "hmac-sha2-512-etm@openssh.com" ];
    };
  };

  # Authorized Keys via sops (NIEMALS im Klartext)
  users.users.mo.openssh.authorizedKeys.keyFiles = [
    config.sops.secrets."ssh-authorized-keys".path
  ];
}
```

---

## VI. LAYER-ARCHITEKTUR: MODULES/

```
modules/
├── 00-core/           Kritisch: OS stirbt ohne diese Layer
│   ├── boot.nix       systemd-boot, UEFI, GRUB-Verbot
│   ├── networking.nix nftables, Basis-Firewall, DHCP/Static
│   ├── ssh.nix        Hardened OpenSSH (CIS-Compliant, s. §V.D)
│   ├── users.nix      User-Definitionen, Gruppen (media GID=169)
│   ├── secrets.nix    sops-nix Integration, age-Key-Management
│   ├── storage.nix    ZFS, Disk-Label-Mounts, MergerFS (s. §IV)
│   └── nftables.nix   Firewall + VPN-Kill-Switch-Basis (s. §V.C)
│
├── 20-server/         Kritisch: Server nicht erreichbar ohne diese
│   ├── caddy.nix      Reverse-Proxy mit UDS-Backend (s. §V.B)
│   ├── adguard.nix    DNS-Resolver + Ad-Blocker
│   ├── tailscale.nix  Zero-Config VPN / Remote-Access
│   ├── cloudflared.nix Tunnel für öffentliche Exposition
│   ├── postgresql.nix  DB für Pocket-ID, Paperless, n8n, etc.
│   ├── valkey.nix      KV-Cache (Redis-Ersatz – Redis: VERBOTEN)
│   └── pocket-id.nix   OIDC-Provider (UDS, Passkey-Only, s. §V.B)
│
├── 30-services/       Betriebskritisch: Täglich genutzte Dienste
│   ├── vaultwarden.nix
│   ├── n8n.nix
│   ├── home-assistant.nix
│   ├── matrix-conduit.nix
│   ├── semaphore.nix
│   ├── homepage.nix
│   └── olivetin.nix    First-Run-Dashboard (USB-Stick-Workflow)
│
├── 40-media/          Audio/Video-Ökosystem
│   ├── jellyfin.nix    (nspawn-Container mit QuickSync, s. §V.A)
│   ├── sonarr.nix
│   ├── radarr.nix
│   ├── prowlarr.nix
│   ├── sabnzbd.nix    (Staging auf DISK_CACHE, s. §IV.E)
│   ├── audiobookshelf.nix
│   ├── jellyseerr.nix
│   └── recyclarr.nix
│
├── 50-knowledge/      Wissens- & Dokumenten-Management
│   ├── paperless.nix
│   ├── miniflux.nix
│   ├── readeck.nix
│   ├── linkding.nix
│   └── karakeep.nix
│
├── 80-monitoring/     Observability-Layer
│   ├── scrutiny.nix   S.M.A.R.T.-Überwachung aller Disks
│   ├── netdata.nix    System-Metriken
│   └── uptime-kuma.nix Service-Verfügbarkeit
│
└── 90-policy/         Build-Zeit-Assertions (kein Laufzeit-Effekt)
    ├── port-collision-guard.nix  Kollisions-Erkennung aller Services
    ├── container-ban.nix         Assertion: Kein Docker/Podman im System
    └── lint.nix                  Allgemeine Architektur-Regeln
```

### Layer-Regel: Kein Zirkel-Bezug

Die Layers 00–90 sind eine **Einbahnstraße**, keine bidirektionale Hierarchie.
Höhere Layer dürfen niedrigere importieren, niemals umgekehrt.

```
00-core ← 20-server ← 30-services ← 40-media ← 50-knowledge ← 80-monitoring ← 90-policy
(Pfeil = "wird importiert von")
```

**Zirkel-Prävention:** `options.my.meta.*` ist dauerhaft verboten (§I, s. Architecture Review).
Service-Metadaten (Port-Nummern, Beschreibungen) leben in `90-policy/port-registry.nix`,
NICHT im Systemkonfigurationsbaum.

```nix
# 90-policy/port-registry.nix – Externes Port-Register (kein NixOS-Options-Missbrauch)
# Dieses File ist NUR für Build-Zeit-Assertions, nicht für runtime-Config!
{
  _module.args.portRegistry = {
    caddy           = 80;
    caddyTLS        = 443;
    adguard         = 3000;
    tailscale       = 41641;  # UDP
    postgresql      = 5432;
    valkey          = 6379;
    pocketId        = 0;      # UDS – kein TCP-Port! ← Kernprinzip §V.B
    jellyfin        = 0;      # UDS – kein TCP-Port!
    vaultwarden     = 0;      # UDS – kein TCP-Port!
    # ... weitere Services
  };
}
```

---

## VII. WISSENSBASIS-STANDARD (DREI-LAYER-PFLICHT)

Jedes Dokument im Almanach MUSS drei Schichten enthalten:

```
Layer 1 – USER (KISS):     Was ist das? Wofür brauche ich es? (≤ 5 Sätze)
Layer 2 – TECHNICAL:       Vollständige Spezifikation, Nix-Code, Flags, Parameter
Layer 3 – REASONING (ADR): Warum diese Entscheidung? Was wurde verworfen? Mit Quelle.
```

### Sieben Qualitäts-Tore (jede .nix-Datei)

| Gate | Prüfung | Tool |
|------|---------|------|
| 1 | Community-Goldstandard: Abgleich mit nixpkgs/modules | context7 |
| 2 | API-Accuracy: Optionen existieren wirklich (Anti-Halluzination) | context7 |
| 3 | SSoT-Compliance: Port-Registry + Secrets via sops | 90-policy |
| 4 | SRE-Hardening: `systemd-analyze security <unit>` < 4.0 | systemd |
| 5 | Dendritische Integrität: Eine Datei = Ein Service | Review |
| 6 | Hygiene & Purity: Kein `options.my.meta.*`, kein toter Code | Review |
| 7 | Traceability: YAML-Header mit Quelle und ADR-Referenz | Review |

### Wissens-Wachstum (Löschverbot absolut)

```
[CONTEXT7-ENRICHMENT]   – Aus Context7 verifiziert
[SEARCH-ENRICHMENT]     – Aus Web-Recherche
[ARCHITECT-NOTE]        – Interne logische Herleitung
[PATTERN-MINING: <repo>]– Aus GitHub-Pattern-Mining
[DEPRECATED]            – Überholt, bleibt im Reasoning Layer erhalten
```

---

## VIII. RAG-FIRST OPERATIONS (AGENTEN-LOGIK)

### A. Query-Zwang

Vor jeder Code-Generierung oder Architektur-Beratung MUSS der Ablauf sein:
```
1. RAG-Vektorstore konsultieren (.vectorstore/ via gemini_cli_query_tool)
2. Almanach-Gesetze cross-referenzieren (/home/Knowledge-Pipeline/Almanach/)
3. Erzmine auf relevante Nuggets prüfen (/home/Knowledge-Pipeline/Erzmine/)
4. Erst dann: Code oder Architektur-Vorschlag
```

### B. Beweispflicht

Jede Datei-Operation wird durch physischen Nachweis belegt:
```bash
# Nach Schreiben:
ls -la /home/Werkstatt/
head -n 5 /home/Werkstatt/<neue-datei>.nix

# Nach Archivierung:
ls -la /home/Knowledge-Pipeline/Erzmine/02-ARCHIVE/versions/

# Reinheits-Nachweis:
ls -la /root/    # MUSS leer oder nur Systemdateien zeigen
```

### C. Anti-Halluzinations-Gesetz

```
PFLICHT:    Bei Nix-Optionen/API-Fragen → context7 ZUERST befragen
VERBOTEN:   "..." oder "wie oben" als Platzhalter (= Systemverstoß)
VERBOTEN:   Simulieren von Tool-Outputs
VERBOTEN:   sed -i auf Systemdateien
VERBOTEN:   pkill auf unbekannte Prozesse
VERBOTEN:   SSH/systemd-Manipulation ohne expliziten Auftrag
VERBOTEN:   Metadaten als Nix-Options (options.my.meta.*)
PFLICHT:    Alles deklarativ über Nix – niemals manuell
```

### D. ISO-Compliance-Check (bei jeder Änderung)

Vor jedem Commit in /home/Werkstatt/ MUSS geprüft werden:
> "Funktioniert dieser Code auch auf einem anderen Rechner mit korrekt gesetzten Labels
> `DISK_SYSTEM`, `DISK_CACHE` und `DISK_STORAGE_*`?"

Wenn die Antwort NEIN ist, muss die Hardware-Referenz abstrahiert werden.

---

## IX. GITHUB-PATTERN-MINING-PROTOKOLL

### Filter-Strategie (nicht blind alles einlesen)

```
Bei Account-Links:
  → Liste nur Repos mit *.nix-Dateien
  → Filter: Tags nixos, homelab, nix-config, self-hosted
  → Nur Repos mit Aktivität in 2024 oder 2025
  → Zeige gefilterte Liste → Mo wählt aus

Erlaubte Dateien:   README.md, flake.nix, *.nix aus modules/ oder hosts/
Verbotene Dateien:  src/ (Quellcode), lock-files, .github/ (CI)
Ziel:               /home/Knowledge-Pipeline/raw/sources/<repo-name>/
Analyse-Output:     /raw/sources/<repo-name>-patterns.md
Veredelung:         Nach /docs/ (Drei-Layer-Standard) auf Anweisung
Markierung:         [PATTERN-MINING: <repo>]
```

---

## X. MCP-SERVER & TOOLING

### Start-Validierung (bei jeder Session)

```
KRITISCH:
  context7        → Primäre Docs-Quelle (NixOS-API-Accuracy)
  nixos           → Nix-Optionen Validierung

WICHTIG:
  open-websearch  → Live Best-Practices
  github          → Referenz-Repository Scans

REGEL: Bei Ausfall eines kritischen MCP-Servers → SOFORT melden.
       Kein stilles Scheitern. Kein Simulieren von Tool-Outputs.
```

---

## XI. GIT-SYNC-PROTOKOLL

```
Werkstatt-Repo: /home/Werkstatt/     → git commit nach jeder .nix-Änderung
Knowledge-Repo: /home/Knowledge-Pipeline/docs/ → Branch main

Commit-Prefix-Konvention:
  adr:       Architecture Decision Records
  services:  Dienst-Konfigurationen
  learnings: Erkenntnisse aus Debugging
  guides:    Schritt-für-Schritt-Anleitungen
  patterns:  GitHub-Pattern-Mining-Ergebnisse
  storage:   Storage/Disk-Konfigurationen
  security:  Sicherheits-Änderungen

Tokens:  Nur via Umgebungsvariablen – NIEMALS im Klartext in .nix oder .md
```

---

## XII. RECONCILIATION LOG & PROVENIENZ

### Was v12.0 gegenüber den Vorgängern hinzufügt

| # | Änderung | Quelle | Vorgänger |
|---|----------|--------|-----------|
| 1 | ADR-040: Law of Associative Mining als operativer Kern | Gemini Architektur-Analyse | — (neu) |
| 2 | Unix Domain Sockets statt TCP für Caddy↔Backend | geminiverbesserung.txt (Erzmine) | — (fehlte) |
| 3 | Verbot `options.my.meta.*` + Begründung | geminiverbesserung.txt (Erzmine) | — (fehlte) |
| 4 | Disk-Label-Standard (DISK_SYSTEM/CACHE/STORAGE_*) | v11.0 | v10.0 (Q958-Slots) |
| 5 | MergerFS-Flags komplett (epmfs+newest+ignore_pp) | v10.0 + ADR-040-Satellites | v11.0 (unvollständig) |
| 6 | VPN Kill-Switch via nftables (vollständig) | v10.0 + ADR-040 | v11.0 (fragment) |
| 7 | SSH CIS-Hardening vollständig | Architecture Review | v7.0 (rudimentär) |
| 8 | Flake-Purity-Gesetz (kein NIX_PATH in Flakes) | Bug-Review (Erzmine) | — (fehlte) |
| 9 | Valkey über Redis (explizit, mit Begründung) | v7.0 | v10.0/v11.0 (implizit) |
| 10| Pfad-Reinheit reaktiviert: /home/Werkstatt/ statt /home/mynixos/ | v7.0+v11.0 | Migration abgeschlossen |
| 11| Systemd-Hardening-Flags für Caddy (CIS-Komplett) | Architecture Review | — (fehlte) |
| 12| Mining-Kaskaden für alle Kern-Technologien | ADR-040 | — (neu) |

---

## XIII. HARDWARE-REFERENZ (INFORMATIV – NICHT NORMATIV)

Die folgende Hardware-Referenz dient ausschließlich als Beispiel-Mapping für die
Erstkonfiguration. Sie ist KEIN Bestandteil der Architektur. Alle Module sind
label-basiert und hardware-agnostisch.

```
[DEPRECATED: Hardware-spezifisch, nur zur Orientierung]
Gerät:       Fujitsu Q958 (Formfaktor: Mini-PC)
CPU:         Intel Core i3-9100 (4C/4T, 3.6 GHz base)
RAM:         16 GB DDR4
GPU:         Intel UHD 630 (QuickSync = iHD, Hardware-Transcoding)
IP:          192.168.2.73 (lokales Netz – nicht normativ)

Tier-Mapping-Beispiel (Q958-spezifisch):
  DISK_SYSTEM    ← Samsung NVMe (M.2 Main-Slot)
  DISK_CACHE     ← Apacer SSD (M.2 WLAN-Slot via Adapter)
  DISK_STORAGE_* ← SATA-HDDs (SATA-Ports 0-N)
```

---

*GEMINI.md v12.0 – Generiert: März 2026*
*Architektur: Mo (Entscheidungsträger) + Claude (Architecture Master) + Gemini CLI (On-Server Execution)*
*Nächste Review: Nach erstem vollständigen nixos-rebuild auf neuer Hardware*
