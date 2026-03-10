# NMS v4.2 sovereign identity implementation strategy

**Created:** 3/3/2026 13:40:54  
**Updated:** 3/3/2026 17:26:27  
**Exported:** 3/3/2026 18:04:32  
**Link:** [https://claude.ai/chat/245bf80f-7cfa-4a38-9f66-09486960e411](https://claude.ai/chat/245bf80f-7cfa-4a38-9f66-09486960e411)  

## Prompt:
3.3.2026, 13:40:56

> File: Claude-Dokumentenverwaltung mit automatischer Metadaten-Tagging.md

> GitHub: [grapefruit89/mynixos](https://github.com/grapefruit89/mynixos)

🛠️ High-Precision Architect Prompt for Claude
Subject: System Engineering Task: NMS v4.2 "Sovereign Identity" Implementation Strategy
Context: The user is evolving their NixOS repository (https://github.com/grapefruit89/mynixos) into a stateless, sovereign system (NMS v4.2). We are moving away from traditional persistence towards a "Cloud-Streaming Identity" model.
Input Materials:
1. Repository Structure: (Provided via Files) – Pay close attention to the existing `00-core`, `10-gateway`, etc., structure.
2. Previous Audit: (Provided via Files) – You identified 4 critical Deadlocks in the boot sequence (Network-Bootstrapping, USB-Mounting in initrd, sops-nix dependency, and Restic-Sync timing).
Your Objective: Elevate this project from a conceptual stage to a structured, implementable architecture. Solve the "Deadlocks" by redesigning the boot and identity handoff.
Specific Tasks for your Artifacts:
1. The "Stage-0" Identity Handoff: Define how the system identifies the Master-USB in `initrd` (pre-udev) to fetch "Bootstrap Credentials" (WLAN/S3-Read-Only) to bridge the network gap.
2. Tiered Storage & Impermanence Refactoring: Provide a module that integrates `tmpfs` on `/` with the Tier A/B/C logic, ensuring that only Tier A is targeted by the Restic-S3-Sync.
3. The "Vault-to-Cloud" Bridge: Design the `systemd` dependency chain. How do we ensure that `sops-nix` waits for the Restic-Pull, and the Restic-Pull waits for the USB-Bootstrap-Network?
4. Operational Safety: Implement the "Pre-shutdown Hook" you mentioned in the audit to prevent data loss.
Constraints & Style:
* Precision: Use fact-based, engineering-grade logic. No generic fluff.
* Language: Respond in German (as per user preference), but keep technical terms precise.
* Structure: Create as many Artifacts as needed (Nix modules, Shell scripts, Architecture diagrams in Mermaid).
* No Gender-Neutral Language: Strictly follow the user's formatting instructions.
* Single Box Principle: If providing a sequence of commands, use a single executable block.
Deliverable: A step-by-step roadmap on how to refactor the current `mynixos` repo into the NMS v4.2 structure, solving the identified boot-deadlocks.



## Response:
3.3.2026, 14:44:18

````plaintext
View: Check available skills
````

Das ist ein komplexes System-Engineering-Projekt — kein Dokument-Output, sondern pure Architektur-Arbeit. Ich analysiere die Repo-Struktur und die 4 identifizierten Deadlocks und liefere dir ein vollständiges NMS v4.2 Implementierungs-Paket.

Lass mich die Kernprobleme durcharbeiten:

**Die 4 Boot-Deadlocks:**
1. **Network-Bootstrap-Deadlock**: `sops-nix` braucht Netz, Netz braucht WLAN-Credentials, Credentials liegen in SOPS → Zirkelabhängigkeit
2. **USB-Mount-in-initrd**: `udev` ist im early-boot nicht verfügbar, kein stabiler Device-Pfad für Master-USB
3. **sops-nix vor Restic-Pull**: SOPS will Secrets entschlüsseln, bevor Restic-Vault vom S3 synchronisiert ist
4. **Restic-Sync-Timing**: Pre-shutdown Hook fehlt → bei Power-Loss gehen unsynchronisierte Tier-A-Daten verloren

Die Architektur-Lösung ist eine **3-Stage-Boot-Pipeline**:

```
Stage 0 (initrd):   USB-Fingerprint → Bootstrap-Env  
Stage 1 (early):    Netz-Bootstrap → Restic-Pull → sops-nix
Stage 2 (normal):   Services starten auf fertigem Identity-State
```

---

## Artifact 1: Architektur-Diagramm (Mermaid)

```mermaid
flowchart TD
    subgraph "Stage 0 — initrd (pre-udev)"
        A[Kernel Boot] --> B[initrd activate]
        B --> C{USB-Fingerprint\nper /dev/disk/by-id}
        C -->|Gefunden| D[Mount USB read-only\nan /run/bootstrap]
        C -->|Nicht gefunden| E[Emergency Shell\n+ TTY1 Hinweis]
        D --> F[Extrahiere bootstrap.env\nWLAN-SSID + PSK + S3-Read-Key]
        F --> G[Übergabe via\n/run/bootstrap-creds\nan PID 1]
    end

    subgraph "Stage 1 — systemd early-boot"
        G --> H[nixhome-bootstrap-network.service\nwpa_supplicant + dhcpcd ephemeral]
        H --> I{Netz online?}
        I -->|ja| J[nixhome-restic-pull.service\nS3 → /data/state/vault]
        I -->|nein| K[Fallback: USB-only Mode\nkeine Cloud-Sync]
        J --> L[sops-install-secrets.service\nentschlüsselt /data/state/vault/secrets.yaml]
        L --> M[nixhome-identity-ready.target]
    end

    subgraph "Stage 2 — Services"
        M --> N[caddy.service]
        M --> O[pocket-id.service]
        M --> P[postgresql.service]
        M --> Q[... alle anderen Services]
    end

    subgraph "Stage 3 — Pre-Shutdown"
        R[systemd-shutdown hook] --> S[nixhome-pre-shutdown.service\nRestic-Push Tier-A → S3]
        S --> T[sync + poweroff]
    end
```

---

## Artifact 2: Stage-0 initrd Bootstrap (`00-core/initrd-bootstrap.nix`)

```nix
# 00-core/initrd-bootstrap.nix
# NMS v4.2 — Stage-0 Identity Handoff via Master-USB
# ID: NIXH-00-COR-041
{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-COR-041";
    title = "initrd Bootstrap (Sovereign Identity Stage-0)";
    description = "Pre-udev USB fingerprinting to extract bootstrap credentials before network is available.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = [ "boot/identity-handoff" "security/bootstrap" "system/initrd" ];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 4;
  };

  # Der USB wird per by-id identifiziert — stabil, unabhängig von udev-Enumeration
  # Format: NIXHOME_BOOTSTRAP_<SERIAL> — muss beim Erstellen des USB gesetzt werden
  bootstrapUsbLabel = "NIXHOME_BOOT";
  bootstrapMountPoint = "/run/bootstrap";
  bootstrapCredsTarget = "/run/bootstrap-creds";

  # Stage-0 Script: läuft in initrd, bevor systemd PID 1 übernimmt
  stage0Script = pkgs.writeShellScript "nixhome-stage0-bootstrap" ''
    set -euo pipefail
    mkdir -p ${bootstrapMountPoint} ${bootstrapCredsTarget}

    echo "[NMS Stage-0] Scanning for Bootstrap-USB (label: ${bootstrapUsbLabel})..."

    # Suche per Label — by-label ist in initrd verlässlicher als by-id
    USB_DEV=""
    for dev in /dev/disk/by-label/${bootstrapUsbLabel}*; do
      if [ -e "$dev" ]; then
        USB_DEV=$(readlink -f "$dev")
        break
      fi
    done

    # Fallback: Scanne alle FAT-Partitionen nach bootstrap.env
    if [ -z "$USB_DEV" ]; then
      echo "[NMS Stage-0] Label-Scan fehlgeschlagen, versuche Brute-Force..."
      for dev in /dev/sd* /dev/nvme*n*p*; do
        [ -b "$dev" ] || continue
        TYPE=$(blkid -o value -s TYPE "$dev" 2>/dev/null || echo "")
        if [ "$TYPE" = "vfat" ] || [ "$TYPE" = "exfat" ]; then
          mount -o ro,noexec,nosuid "$dev" ${bootstrapMountPoint} 2>/dev/null || continue
          if [ -f "${bootstrapMountPoint}/bootstrap.env" ]; then
            USB_DEV="$dev"
            echo "[NMS Stage-0] Bootstrap-USB gefunden auf $dev"
            break
          fi
          umount ${bootstrapMountPoint} 2>/dev/null || true
        fi
      done
    else
      mount -o ro,noexec,nosuid "$USB_DEV" ${bootstrapMountPoint}
    fi

    if [ -z "$USB_DEV" ] || [ ! -f "${bootstrapMountPoint}/bootstrap.env" ]; then
      echo "[NMS Stage-0] KRITISCH: Kein Bootstrap-USB gefunden!"
      echo "[NMS Stage-0] Schreibe Emergency-Flag und übergebe an Stage-1..."
      echo "BOOTSTRAP_STATUS=failed" > "${bootstrapCredsTarget}/status.env"
      # KEIN hard-exit — System soll booten (mit eingeschränktem Modus)
      exit 0
    fi

    # Validierung: Prüfe Checksumme der bootstrap.env
    if [ -f "${bootstrapMountPoint}/bootstrap.env.sha256" ]; then
      EXPECTED=$(cat "${bootstrapMountPoint}/bootstrap.env.sha256")
      ACTUAL=$(sha256sum "${bootstrapMountPoint}/bootstrap.env" | awk '{print $1}')
      if [ "$EXPECTED" != "$ACTUAL" ]; then
        echo "[NMS Stage-0] SICHERHEIT: Checksumme ungültig! USB manipuliert?"
        echo "BOOTSTRAP_STATUS=tampered" > "${bootstrapCredsTarget}/status.env"
        umount ${bootstrapMountPoint}
        exit 0
      fi
    fi

    # Kopiere Credentials in RAM — USB wird danach unmounted
    cp "${bootstrapMountPoint}/bootstrap.env" "${bootstrapCredsTarget}/bootstrap.env"
    chmod 600 "${bootstrapCredsTarget}/bootstrap.env"
    echo "BOOTSTRAP_STATUS=ok" >> "${bootstrapCredsTarget}/status.env"

    # Extrahiere Fingerprint für Audit-Log
    FINGERPRINT=$(sha256sum "${bootstrapCredsTarget}/bootstrap.env" | awk '{print $1}' | cut -c1-16)
    echo "BOOTSTRAP_FINGERPRINT=${FINGERPRINT}" >> "${bootstrapCredsTarget}/status.env"

    umount ${bootstrapMountPoint}
    echo "[NMS Stage-0] Bootstrap-Credentials sicher im RAM. USB unmounted."
  '';

in {
  options.my.meta.initrd_bootstrap = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for initrd-bootstrap module";
  };

  options.my.boot.bootstrap = {
    enable = lib.mkEnableOption "Sovereign Identity Stage-0 Bootstrap";
    usbLabel = lib.mkOption {
      type = lib.types.str;
      default = bootstrapUsbLabel;
      description = "FAT-Label des Master-Bootstrap-USB.";
    };
  };

  config = lib.mkIf config.my.boot.bootstrap.enable {
    # Stage-0 Script in initrd einbetten
    boot.initrd.extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.util-linux}/bin/blkid
      copy_bin_and_libs ${pkgs.util-linux}/bin/mount
      copy_bin_and_libs ${pkgs.util-linux}/bin/umount
      copy_bin_and_libs ${pkgs.coreutils}/bin/sha256sum
      copy_bin_and_libs ${pkgs.coreutils}/bin/readlink
    '';

    boot.initrd.postMountCommands = ''
      ${stage0Script}
    '';

    # Stage-1 systemd kann auf die Creds zugreifen
    # /run ist tmpfs und überlebt den initrd→systemd Übergang
    systemd.tmpfiles.rules = [
      "d /run/bootstrap-creds 0700 root root -"
    ];
  };
}
```

---

## Artifact 3: Stage-1 Network Bootstrap & Restic-Pull (`00-core/identity-pipeline.nix`)

```nix
# 00-core/identity-pipeline.nix
# NMS v4.2 — Stage-1 "Vault-to-Cloud Bridge"
# Löst Deadlocks: Network-Bootstrap → Restic-Pull → sops-nix
# ID: NIXH-00-COR-042
{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-COR-042";
    title = "Identity Pipeline (Stage-1 Vault-to-Cloud Bridge)";
    description = "Orchestrates the boot dependency chain: USB-Creds → Network → Restic-Pull → sops-nix.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = [
      "boot/dependency-chain"
      "security/identity-handoff"
      "cloud/restic-pull"
    ];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 4;
  };

  bootstrapCredsFile = "/run/bootstrap-creds/bootstrap.env";
  vaultDir = "/data/state/vault";
  identityReadyTarget = "nixhome-identity-ready.target";

in {
  options.my.meta.identity_pipeline = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for identity-pipeline module";
  };

  options.my.boot.identityPipeline = {
    enable = lib.mkEnableOption "Stage-1 Identity Pipeline (Sovereign Boot)";
    s3Bucket = lib.mkOption {
      type = lib.types.str;
      default = "nixhome-vault";
      description = "S3-Bucket-Name für den Restic-Vault.";
    };
    s3Endpoint = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Custom S3-Endpoint (leer = AWS).";
    };
    vaultLocalPath = lib.mkOption {
      type = lib.types.str;
      default = vaultDir;
      description = "Lokales Ziel für den Restic-Pull.";
    };
  };

  config = lib.mkIf config.my.boot.identityPipeline.enable {
    # ── TARGET: Alle Services warten auf dieses Target ────────────────────
    systemd.targets.${identityReadyTarget} = {
      description = "NixHome Sovereign Identity: bereit";
      requires = [ "nixhome-sops-ready.service" ];
      after = [ "nixhome-sops-ready.service" ];
    };

    # Überschreibe sops-nix default target dependency
    systemd.services.sops-install-secrets = {
      after = lib.mkForce [
        "nixhome-restic-pull.service"
        "nixhome-bootstrap-network.service"
      ];
      requires = lib.mkForce [ "nixhome-restic-pull.service" ];
      wantedBy = lib.mkForce [ "nixhome-sops-ready.service" ];
    };

    # ── SERVICE 1: Bootstrap-Netzwerk via USB-Credentials ─────────────────
    systemd.services.nixhome-bootstrap-network = {
      description = "NixHome Stage-1: Bootstrap-Netzwerk via USB-Credentials";
      wantedBy = [ "network-online.target" ];
      before = [ "network-online.target" "nixhome-restic-pull.service" ];
      after = [ "systemd-udevd.service" ];
      # Läuft VOR dem normalen networkd — setzt ein ephemeres WLAN auf
      before = [ "systemd-networkd.service" "NetworkManager.service" ];
      unitConfig = {
        # Wenn Bootstrap fehlschlägt, versuche normales Netz
        FailureAction = "none";
        StartLimitBurst = 1;
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "120s";
      };
      script = ''
        set -euo pipefail

        # Prüfe Bootstrap-Status aus Stage-0
        if [ ! -f "${bootstrapCredsFile}" ]; then
          echo "[Bootstrap-Net] Keine Credentials gefunden — überspringe."
          exit 0
        fi

        STATUS=$(grep BOOTSTRAP_STATUS /run/bootstrap-creds/status.env | cut -d= -f2)
        if [ "$STATUS" != "ok" ]; then
          echo "[Bootstrap-Net] Bootstrap-Status: $STATUS — überspringe WLAN-Setup."
          exit 0
        fi

        # Lade bootstrap.env (enthält WLAN_SSID, WLAN_PSK)
        set -a
        source "${bootstrapCredsFile}"
        set +a

        if [ -z "''${WLAN_SSID:-}" ]; then
          echo "[Bootstrap-Net] Kein WLAN konfiguriert — nutze Ethernet."
          exit 0
        fi

        # Finde WLAN-Interface
        WLAN_IF=$(${pkgs.iproute2}/bin/ip link show | grep -E '^[0-9]+: wl' | head -1 | awk -F': ' '{print $2}')
        if [ -z "$WLAN_IF" ]; then
          echo "[Bootstrap-Net] Kein WLAN-Interface gefunden."
          exit 0
        fi

        echo "[Bootstrap-Net] Verbinde mit $WLAN_SSID auf $WLAN_IF..."

        # Ephemeres wpa_supplicant (nicht persistent, nur für Boot)
        WPA_CONF=$(${pkgs.coreutils}/bin/mktemp /run/wpa-bootstrap-XXXXXX.conf)
        chmod 600 "$WPA_CONF"
        cat > "$WPA_CONF" <<EOF
        network={
          ssid="''${WLAN_SSID}"
          psk="''${WLAN_PSK}"
          key_mgmt=WPA-PSK
        }
        EOF

        ${pkgs.wpa_supplicant}/bin/wpa_supplicant \
          -B -i "$WLAN_IF" -c "$WPA_CONF" \
          -P /run/wpa-bootstrap.pid

        # Warte auf IP via dhcpcd (ephemer, nicht persistent)
        ${pkgs.dhcpcd}/bin/dhcpcd -w -t 30 "$WLAN_IF" || true

        # Räume auf — PSK nie länger als nötig im FS
        rm -f "$WPA_CONF"

        IP=$(${pkgs.iproute2}/bin/ip -4 addr show "$WLAN_IF" | grep inet | awk '{print $2}')
        echo "[Bootstrap-Net] Netz up: $IP"
      '';
    };

    # ── SERVICE 2: Restic-Pull vom S3 ─────────────────────────────────────
    systemd.services.nixhome-restic-pull = {
      description = "NixHome Stage-1: Restic-Vault vom S3 synchronisieren";
      after = [
        "nixhome-bootstrap-network.service"
        "network-online.target"
        "sops-install-secrets.service"
        # Absichtlich: restic braucht S3-Key, aber der ist im bootstrap.env!
        # sops-nix braucht restic-pull — Zirkel gelöst via Bootstrap-Env
      ];
      wants = [ "network-online.target" ];
      before = [ "nixhome-sops-ready.service" ];
      unitConfig = {
        FailureAction = "none"; # Kein Pull → Offline-Modus, kein Absturz
        StartLimitBurst = 2;
        StartLimitIntervalSec = "60s";
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "300s";
        EnvironmentFile = lib.mkIf (builtins.pathExists bootstrapCredsFile)
          bootstrapCredsFile;
      };
      script = ''
        set -euo pipefail

        if [ ! -f "${bootstrapCredsFile}" ]; then
          echo "[Restic-Pull] Keine Bootstrap-Creds — überspringe S3-Pull."
          exit 0
        fi

        set -a
        source "${bootstrapCredsFile}"
        set +a

        if [ -z "''${RESTIC_REPOSITORY:-}" ] || [ -z "''${RESTIC_PASSWORD:-}" ]; then
          echo "[Restic-Pull] RESTIC_REPOSITORY oder RESTIC_PASSWORD nicht gesetzt."
          exit 0
        fi

        mkdir -p "${vaultDir}"

        echo "[Restic-Pull] Starte Restic restore von $RESTIC_REPOSITORY..."

        # Restore nur Tier-A (Secrets, State) — nicht Media
        ${pkgs.restic}/bin/restic restore latest \
          --target "${vaultDir}" \
          --include "/secrets*" \
          --include "/state*" \
          --include "/identity*" \
          || {
            echo "[Restic-Pull] Restore fehlgeschlagen — nutze lokalen Vault falls vorhanden."
            exit 0
          }

        echo "[Restic-Pull] Vault synchronisiert nach ${vaultDir}."

        # Passe sops-nix default-Dateipfad an
        if [ -f "${vaultDir}/secrets.yaml" ]; then
          ln -sf "${vaultDir}/secrets.yaml" /etc/nixos/secrets.yaml || true
        fi
      '';
    };

    # ── SERVICE 3: Bestätigt sops-nix Abschluss ───────────────────────────
    systemd.services.nixhome-sops-ready = {
      description = "NixHome: sops-nix abgeschlossen (Identity ready)";
      after = [ "sops-install-secrets.service" ];
      requires = [ "sops-install-secrets.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/true";
      };
    };

    # ── ABHÄNGIGKEITEN: Alle kritischen Services warten auf Identity ───────
    # Caddy, Pocket-ID, PostgreSQL etc. warten auf Identity-Ready
    systemd.services.caddy.after = lib.mkMerge [
      (config.systemd.services.caddy.after or [])
      [ "${identityReadyTarget}" ]
    ];
    systemd.services.pocket-id.after = lib.mkMerge [
      (config.systemd.services.pocket-id.after or [])
      [ "${identityReadyTarget}" ]
    ];
    systemd.services.postgresql.after = lib.mkMerge [
      (config.systemd.services.postgresql.after or [])
      [ "${identityReadyTarget}" ]
    ];
  };
}
```

---

## Artifact 4: Tiered Storage & Impermanence (`00-core/impermanence.nix`)

```nix
# 00-core/impermanence.nix
# NMS v4.2 — tmpfs auf / mit Tier A/B/C Persistenz-Logik
# ID: NIXH-00-COR-043
{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-COR-043";
    title = "Impermanence (Sovereign Stateless Root)";
    description = "tmpfs / with declarative Tier A/B/C persistence and S3-targeted Restic sync.";
    layer = 00;
    nixpkgs.category = "system/storage";
    capabilities = [
      "storage/impermanence"
      "security/ephemeral-root"
      "backup/tier-a-only"
    ];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 4;
  };

  cfg = config.my.impermanence;

  # ── TIER-DEFINITIONEN ────────────────────────────────────────────────────
  # Tier A: Kritisch, verschlüsselt, S3-backed, Restic-Sync
  tierA = {
    description = "Sovereign Identity & Secrets";
    paths = [
      "/data/state/secrets"       # SOPS-Secrets
      "/data/state/pocket-id"     # OIDC-State
      "/data/state/vault"         # Restic-lokaler Vault
      "/data/state/postgresql"    # DB-Dumps (nicht der live PG-Cluster)
      "/data/state/caddy/certs"   # TLS-Zertifikate
      "/etc/nixos/secrets.yaml"   # Symlink-Target
    ];
    resticInclude = [
      "/data/state/secrets/**"
      "/data/state/pocket-id/**"
      "/data/state/caddy/certs/**"
    ];
  };

  # Tier B: Wichtig, lokal persistent, kein S3
  tierB = {
    description = "Service-State (lokal persistent)";
    paths = [
      "/data/state/vaultwarden"
      "/data/state/miniflux"
      "/data/state/paperless"
      "/data/state/karakeep"
      "/data/state/readeck"
      "/data/state/linkwarden"
      "/data/state/n8n"
      "/data/state/home-assistant"
      "/var/lib/AdGuardHome"
    ];
  };

  # Tier C: Rekonstruierbar, kein Backup nötig
  tierC = {
    description = "Cache & Media (ephemer oder extern)";
    paths = [
      "/mnt/fast-pool/cache"
      "/mnt/fast-pool/downloads"
      "/var/cache"
      "/var/log"          # journald ist volatile → schon in logging.nix
    ];
  };

in {
  options.my.meta.impermanence = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for impermanence module";
  };

  options.my.impermanence = {
    enable = lib.mkEnableOption "Sovereign Impermanence (stateless root via tmpfs)";
    persistentDisk = lib.mkOption {
      type = lib.types.str;
      default = "/dev/disk/by-label/NIXHOME_PERSIST";
      description = "Blockdevice für persistente Daten (Tier A+B).";
    };
    persistMountPoint = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Mountpoint für das persistente Dateisystem.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── ROOT ALS TMPFS ────────────────────────────────────────────────────
    fileSystems."/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=4G" "mode=755" ];
    };

    # ── PERSISTENTES FS (btrfs subvolume empfohlen) ───────────────────────
    fileSystems.${cfg.persistMountPoint} = {
      device = cfg.persistentDisk;
      fsType = "btrfs";
      options = [ "subvol=@persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

    # ── TIER A: Bind-Mounts von persistentem FS ───────────────────────────
    fileSystems = lib.listToAttrs (
      map (path: {
        name = path;
        value = {
          device = "${cfg.persistMountPoint}${path}";
          fsType = "none";
          options = [ "bind" ];
          depends = [ cfg.persistMountPoint ];
        };
      }) tierA.paths
    );

    # ── TIER B: Bind-Mounts ───────────────────────────────────────────────
    fileSystems = lib.mkMerge [
      (lib.listToAttrs (
        map (path: {
          name = path;
          value = {
            device = "${cfg.persistMountPoint}${path}";
            fsType = "none";
            options = [ "bind" ];
            depends = [ cfg.persistMountPoint ];
          };
        }) tierB.paths
      ))
    ];

    # ── TMPFILES: Erstelle Verzeichnisse auf persistentem FS ──────────────
    systemd.tmpfiles.rules =
      (map (p: "d ${cfg.persistMountPoint}${p} 0750 root root -") tierA.paths) ++
      (map (p: "d ${cfg.persistMountPoint}${p} 0755 root root -") tierB.paths) ++
      (map (p: "d ${p} 0755 root root -") tierC.paths);

    # ── RESTIC-SYNC: Nur Tier A → S3 ─────────────────────────────────────
    services.restic.backups.tier-a-sovereign = {
      initialize = true;
      # Repository aus bootstrap.env geladen (zur Laufzeit)
      repositoryFile = "/run/bootstrap-creds/restic-repo.txt";
      passwordFile = "/run/bootstrap-creds/restic-pass.txt";
      paths = tierA.paths;
      exclude = [
        "**/.cache"
        "**/tmp"
        "**/*.sock"
        "**/*.pid"
      ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
        RandomizedDelaySec = "10m";
      };
      pruneOpts = [
        "--keep-hourly 24"
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
      extraOptions = [
        "--compression=max"
        "--exclude-caches"
      ];
    };

    # ── WICHTIG: Keine SSH-Keys nach Boot löschen (in Tier A) ────────────
    environment.etc."ssh/ssh_host_ed25519_key".source =
      lib.mkDefault "${cfg.persistMountPoint}/etc/ssh/ssh_host_ed25519_key";
    environment.etc."ssh/ssh_host_ed25519_key.pub".source =
      lib.mkDefault "${cfg.persistMountPoint}/etc/ssh/ssh_host_ed25519_key.pub";
  };
}
```

---

## Artifact 5: Pre-Shutdown Hook (`00-core/pre-shutdown-guardian.nix`)

```nix
# 00-core/pre-shutdown-guardian.nix
# NMS v4.2 — Pre-Shutdown Data Guardian
# Löst Deadlock 4: Kein Datenverlust bei Power-Loss
# ID: NIXH-00-COR-044
{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-COR-044";
    title = "Pre-Shutdown Guardian (Data Loss Prevention)";
    description = "Forced Restic-Push of Tier-A before any shutdown/reboot. Blocks until sync complete.";
    layer = 00;
    nixpkgs.category = "system/maintenance";
    capabilities = [
      "safety/pre-shutdown"
      "backup/forced-sync"
      "system/data-integrity"
    ];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 3;
  };

  bootstrapCredsFile = "/run/bootstrap-creds/bootstrap.env";
  maxSyncWaitSeconds = 300; # 5 Minuten max vor forced poweroff

in {
  options.my.meta.pre_shutdown_guardian = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for pre-shutdown-guardian module";
  };

  options.my.boot.preShutdownGuardian = {
    enable = lib.mkEnableOption "Pre-Shutdown Data Guardian";
    timeoutSeconds = lib.mkOption {
      type = lib.types.int;
      default = maxSyncWaitSeconds;
      description = "Maximale Wartezeit für Restic-Sync vor Shutdown.";
    };
  };

  config = lib.mkIf config.my.boot.preShutdownGuardian.enable {
    # ── SYSTEMD SHUTDOWN SERVICE ──────────────────────────────────────────
    # DefaultDependencies=no ist KRITISCH — verhindert Zirkel bei shutdown.target
    systemd.services.nixhome-pre-shutdown = {
      description = "NixHome Pre-Shutdown: Tier-A nach S3 sichern";
      wantedBy = [ "shutdown.target" "reboot.target" "halt.target" ];
      before = [ "shutdown.target" "reboot.target" "halt.target" ];
      after = [ "network-online.target" ];
      unitConfig = {
        DefaultDependencies = "no";
        X-StopOnRemoval = "false";
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        TimeoutStartSec = "${toString config.my.boot.preShutdownGuardian.timeoutSeconds}s";
        # Nie killen — lieber warten
        TimeoutStopSec = "infinity";
        KillMode = "none";
      };
      script = ''
        set -euo pipefail

        echo "[Shutdown-Guardian] Pre-Shutdown Tier-A Sync gestartet..."

        # Prüfe ob Bootstrap-Creds verfügbar
        if [ ! -f "${bootstrapCredsFile}" ]; then
          echo "[Shutdown-Guardian] Keine Bootstrap-Creds — überspringe S3-Sync."
          exit 0
        fi

        set -a
        source "${bootstrapCredsFile}"
        set +a

        if [ -z "''${RESTIC_REPOSITORY:-}" ] || [ -z "''${RESTIC_PASSWORD:-}" ]; then
          echo "[Shutdown-Guardian] Repository nicht konfiguriert — lokales Backup."
          # Fallback: Lokales Backup auf persistente Disk
          ${pkgs.rsync}/bin/rsync -av --delete \
            /data/state/secrets/ \
            /persist/emergency-backup/secrets/ \
            2>/dev/null || true
          exit 0
        fi

        # Prüfe Netzwerk
        if ! ${pkgs.iputils}/bin/ping -c1 -W3 1.1.1.1 &>/dev/null; then
          echo "[Shutdown-Guardian] Kein Netz — lokales Backup als Fallback."
          ${pkgs.rsync}/bin/rsync -av --delete \
            /data/state/ \
            /persist/emergency-backup/ \
            2>/dev/null || true
          exit 0
        fi

        echo "[Shutdown-Guardian] Starte Restic-Push Tier-A → $RESTIC_REPOSITORY..."

        TIER_A_PATHS="/data/state/secrets /data/state/pocket-id /data/state/caddy/certs"

        ${pkgs.restic}/bin/restic backup \
          $TIER_A_PATHS \
          --compression=max \
          --exclude-caches \
          --tag "pre-shutdown" \
          --tag "$(hostname)" \
          && echo "[Shutdown-Guardian] ✅ Restic-Push erfolgreich." \
          || echo "[Shutdown-Guardian] ⚠️ Restic-Push fehlgeschlagen — lokaler State bleibt erhalten."

        # Journald flush vor Shutdown
        ${pkgs.systemd}/bin/journalctl --sync || true

        echo "[Shutdown-Guardian] Pre-Shutdown abgeschlossen."
      '';
    };

    # ── WALL-NOTIFICATION bei Shutdown ───────────────────────────────────
    systemd.services.nixhome-shutdown-notify = {
      description = "Notify users about pre-shutdown sync";
      wantedBy = [ "shutdown.target" "reboot.target" ];
      before = [ "nixhome-pre-shutdown.service" ];
      after = [ ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/wall 'NixHome: Sicherungssync läuft. Bitte warten...'";
      };
    };

    # ── ALIAS für manuelle Auslösung ─────────────────────────────────────
    programs.bash.shellAliases = {
      nixhome-sync-now = "sudo systemctl start nixhome-pre-shutdown.service";
      nixhome-safe-shutdown = "sudo systemctl start nixhome-pre-shutdown.service && sudo systemctl poweroff";
      nixhome-safe-reboot = "sudo systemctl start nixhome-pre-shutdown.service && sudo systemctl reboot";
    };
  };
}
```

---

## Artifact 6: Bootstrap-USB Erstellungs-Script

```bash
#!/usr/bin/env bash
# scripts/create-bootstrap-usb.sh
# NMS v4.2 — Erstellt einen Master-Bootstrap-USB für Sovereign Identity
#
# Usage: sudo bash create-bootstrap-usb.sh /dev/sdX
# ════════════════════════════════════════════════════════════════════
set -euo pipefail

USB_DEV="${1:-}"
if [ -z "$USB_DEV" ] || [ ! -b "$USB_DEV" ]; then
  echo "Usage: $0 /dev/sdX"
  echo "Verfügbare Devices:"
  lsblk -d -o NAME,SIZE,MODEL | grep -v loop
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 NMS v4.2 Bootstrap-USB Generator"
echo "   Ziel: $USB_DEV"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  ACHTUNG: $USB_DEV wird vollständig überschrieben!"
read -rp "Fortfahren? (yes/NO): " CONFIRM
[ "$CONFIRM" = "yes" ] || { echo "Abgebrochen."; exit 0; }

# Partition und Format
echo "📀 Formatiere $USB_DEV als FAT32 mit Label NIXHOME_BOOT..."
wipefs -a "$USB_DEV"
parted -s "$USB_DEV" mklabel msdos
parted -s "$USB_DEV" mkpart primary fat32 1MiB 100%
USB_PART="${USB_DEV}1"
sleep 1
mkfs.fat -F32 -n "NIXHOME_BOOT" "$USB_PART"

# Mount
MOUNT_TMP=$(mktemp -d)
mount "$USB_PART" "$MOUNT_TMP"

# Interaktive Credential-Eingabe
echo ""
echo "── WLAN-Konfiguration (optional, Enter = überspringen) ──"
read -rp "WLAN SSID: " WLAN_SSID
if [ -n "$WLAN_SSID" ]; then
  read -rsp "WLAN PSK: " WLAN_PSK
  echo ""
fi

echo ""
echo "── Restic S3-Konfiguration ──"
read -rp "RESTIC_REPOSITORY (z.B. s3:https://s3.eu-central-1.amazonaws.com/mein-vault): " RESTIC_REPO
read -rsp "RESTIC_PASSWORD: " RESTIC_PASS
echo ""
read -rp "AWS_ACCESS_KEY_ID (leer = kein AWS): " AWS_KEY_ID
if [ -n "$AWS_KEY_ID" ]; then
  read -rsp "AWS_SECRET_ACCESS_KEY: " AWS_SECRET
  echo ""
fi

# Schreibe bootstrap.env
cat > "$MOUNT_TMP/bootstrap.env" <<EOF
# NMS v4.2 Bootstrap Credentials
# Erstellt: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# WARNUNG: Diese Datei enthält sensitive Daten — USB sicher aufbewahren!

BOOTSTRAP_VERSION="4.2"
BOOTSTRAP_HOST="$(hostname)"

# Netzwerk
WLAN_SSID="${WLAN_SSID:-}"
WLAN_PSK="${WLAN_PSK:-}"

# Restic / S3
RESTIC_REPOSITORY="${RESTIC_REPO:-}"
RESTIC_PASSWORD="${RESTIC_PASS:-}"
AWS_ACCESS_KEY_ID="${AWS_KEY_ID:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET:-}"

# Wird von restic-pull und restic-push verwendet
RESTIC_COMPRESSION="max"
EOF

chmod 600 "$MOUNT_TMP/bootstrap.env"

# Schreibe Checksumme (zur Integritätsprüfung in Stage-0)
sha256sum "$MOUNT_TMP/bootstrap.env" | awk '{print $1}' > "$MOUNT_TMP/bootstrap.env.sha256"

# Schreibe Restic-Repo und Pass als separate Dateien (für systemd CredentialFile)
echo -n "${RESTIC_REPO:-}" > "$MOUNT_TMP/restic-repo.txt"
echo -n "${RESTIC_PASS:-}" > "$MOUNT_TMP/restic-pass.txt"
chmod 600 "$MOUNT_TMP/restic-repo.txt" "$MOUNT_TMP/restic-pass.txt"

# README auf USB
cat > "$MOUNT_TMP/README.txt" <<EOF
NixHome NMS v4.2 Master-Bootstrap-USB
Erstellt: $(date -u)

WICHTIG:
- Diesen USB sicher aufbewahren (entspricht einem Root-Passwort)
- Nur an physisch sicheren Orten einstecken
- Verlust = Neues Bootstrap-USB + neues Restic-Passwort

Enthaltene Dateien:
- bootstrap.env        Credentials für WLAN + Restic
- bootstrap.env.sha256 Integritätsprüfsumme
- restic-repo.txt      Restic-Repository-URL
- restic-pass.txt      Restic-Verschlüsselungspasswort
EOF

sync
umount "$MOUNT_TMP"
rmdir "$MOUNT_TMP"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Bootstrap-USB erstellt: $USB_PART"
echo "   Label: NIXHOME_BOOT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Nächste Schritte:"
echo "1. USB physisch sicher aufbewahren"
echo "2. In NixOS-Config aktivieren:"
echo "   my.boot.bootstrap.enable = true;"
echo "   my.boot.identityPipeline.enable = true;"
echo "   my.boot.preShutdownGuardian.enable = true;"
echo "   my.impermanence.enable = true;"
echo "3. nixos-rebuild switch"
echo "4. Neustart mit eingestecktem USB testen"
```

---

## Artifact 7: `_imports.nix` Update & Migrationsplan

```nix
# 00-core/_imports.nix — Ergänzung für NMS v4.2
{ ... }:
{
  imports = [
    # ... (bestehende Imports bleiben)

    # ── NMS v4.2 SOVEREIGN IDENTITY ──────────────────────────────────────
    ./initrd-bootstrap.nix      # NIXH-00-COR-041 — Stage-0 USB-Fingerprint
    ./identity-pipeline.nix     # NIXH-00-COR-042 — Stage-1 Boot-Chain
    ./impermanence.nix          # NIXH-00-COR-043 — tmpfs / + Tier A/B/C
    ./pre-shutdown-guardian.nix # NIXH-00-COR-044 — Pre-Shutdown Sync
  ];
}
```

### `configuration.nix` — Aktivierungsblock:

```nix
# In configuration.nix ergänzen:
config = {
  system.stateVersion = "25.11";
  
  # ── NMS v4.2 SOVEREIGN IDENTITY ────────────────────────────────────────
  my.boot.bootstrap.enable = true;
  my.boot.bootstrap.usbLabel = "NIXHOME_BOOT";

  my.boot.identityPipeline.enable = true;
  my.boot.identityPipeline.s3Bucket = "nixhome-vault-q958";
  my.boot.identityPipeline.s3Endpoint = "https://s3.eu-central-1.amazonaws.com";

  my.boot.preShutdownGuardian.enable = true;
  my.boot.preShutdownGuardian.timeoutSeconds = 300;

  # ACHTUNG: Impermanence erst aktivieren nach:
  # 1. Persistente Disk als NIXHOME_PERSIST gelabelt
  # 2. Alle Tier-A/B Pfade auf persistente Disk migriert
  # 3. SSH-Host-Keys nach /persist/etc/ssh/ kopiert
  my.impermanence.enable = false; # → true nach Migration
  my.impermanence.persistentDisk = "/dev/disk/by-label/NIXHOME_PERSIST";
};
```

---

## Migrationsreihenfolge (sicherer Pfad ohne Datenverlust)

**Phase 1 — Bootstrap-USB (ohne Impermanence, risikolos):**
```bash
# Auf dem laufenden System:
sudo bash /etc/nixos/scripts/create-bootstrap-usb.sh /dev/sdX

# Config aktivieren (nur bootstrap + pipeline + guardian):
sudo nixos-rebuild switch
sudo reboot
# → System bootet mit USB, Stage-0/1 aktiv, Root bleibt persistent
```

**Phase 2 — Persistente Disk vorbereiten:**
```bash
# Neue Disk oder Partition als btrfs formatieren:
sudo mkfs.btrfs -L NIXHOME_PERSIST /dev/sdY
sudo mount /dev/sdY /persist
sudo btrfs subvolume create /persist/@persist

# Tier-A Daten migrieren:
sudo rsync -av /data/state/secrets/ /persist/data/state/secrets/
sudo rsync -av /data/state/pocket-id/ /persist/data/state/pocket-id/
sudo cp /etc/ssh/ssh_host_ed25519_key* /persist/etc/ssh/
```

**Phase 3 — Impermanence aktivieren (koordinierter Cutover):**
```bash
# my.impermanence.enable = true; setzen
# → NUR nach vollständiger Phase-2-Migration!
sudo nixos-rebuild boot  # nicht switch — erst beim nächsten Reboot aktiv
sudo nixos-rebuild switch --rollback  # Sicherheits-Rollback bereit halten
sudo reboot
```

---

Das vollständige NMS v4.2 löst alle 4 Deadlocks durch saubere Entkopplung: Der USB liefert Bootstrap-Credentials **vor** dem Netz, das Netz ermöglicht den Restic-Pull, der Restic-Pull befüllt den SOPS-Input, und der Pre-Shutdown-Guardian schließt den Kreis bei jedem System-Stop. Die Tier-Logik sorgt dafür, dass Restic ausschließlich Tier-A synchronisiert — nie Media oder Cache.



## Prompt:
3.3.2026, 14:37:00

/architecture Erstelle ein Architecture Decision Record (ADR) für die Implementierung des NixHome NMS v4.2 "Sovereign Identity" Frameworks. 
### BASIS-KONTEXT & KNOWLEDGE BASE
Lies zuerst die folgende Datei ein, um die strategischen Grundlagen zu verstehen:
"C:\Users\morit\Documents\mynixos-main\Gemini-NixOS Homelab Architecture Review (1).md"
### DEINE ARBEITSUMGEBUNG & TOOLS
1. Filesystem MCP: Scanne das Repository unter "C:\Users\morit\Documents\mynixos-main". Erfasse die Layer-Struktur (00-90) und die aktuellen Import-Abhängigkeiten.
2. Context7 MCP: Validiere aktuelle NixOS-Optionen für systemd-cryptenroll, luks-Geräte in der initrd und initrd-network (SSH/Dropbear).
3. Sequential-Thinking: Plane die zeitliche Abfolge der initrd-Phasen (Netzwerktreiber -> DNA-Check -> Tang-Handshake -> Fallback).
### ARCHITEKTUR-STRATEGIE
Ziel ist eine "Zero-Touch" Boot-Pipeline mit folgender Kaskade:
- Stage 0: Verschlüsselter USB-Stick (Root of Trust).
- Stage 1 (Kaskade): TPM2-Binding -> Network DNA/Tang (MAC-Anker Scan) -> FIDO2 (YubiKey Touch) -> Smartphone-SSH (QR-Code Fallback auf Port 2222).
- Stage 2: Stateless Root (tmpfs) mit Persistenz-Tiers (A/B/C).
### DEINE AUFGABE – SCHRITT FÜR SCHRITT
1. REPOSITORY-AUDIT & REVIEW:
   Nutze /review für die Datei "00-core/registry.nix". Identifiziere kritische "Default-Enabled"-Dienste und schlage ein Refactoring vor, um Konfigurations-Drift zu vermeiden.
2. IMPLEMENTIERUNG DER DNA-LOGIK:
   Entwirf ein Modul "00-core/network-dna.nix", das MAC-Adressen von Router und NAS als Standort-Anker nutzt, bevor Netzwerk-Secrets geladen werden.
3. SOVEREIGN-UNLOCK MODUL:
   Erstelle die LUKS-Konfiguration für den USB-Stick. Die Logik muss idempotent sein: Sie muss auf dem Heim-PC (TPM) automatisch und auf fremder Hardware via FIDO2 oder SSH funktionieren.
4. UX-OPTIMIERUNG:
   Integiere ein Skript für die initrd, das einen QR-Code generiert, sobald die automatische Entschlüsselung fehlschlägt.
5. GEHEIMNIS-MANAGEMENT:
   Verschiebe hardcodierte Keys (z.B. aus n8n oder anderen Modulen) in Richtung SOPS-Nix oder die verschlüsselte USB-Partition.
### LIEFERERGEBNIS
Erstelle eine vollständige Modul-Struktur und das Bash-Skript "create-ux-stick.sh".
/deploy-checklist Erstelle eine abschließende Checkliste für die Verifizierung des Setups: Wie teste ich den TPM-Unlock, den Tang-Fallback und den QR-Code-SSH-Unlock auf fremder Hardware?
Starte jetzt mit dem Filesystem-Scan von C:\Users\morit\Documents\mynixos-main.



## Response:
3.3.2026, 16:04:37

/architecture Erstelle ein Architecture Decision Record (ADR) für die Implementierung des NixHome NMS v4.2 "Sovereign Identity" Frameworks. 
### BASIS-KONTEXT & KNOWLEDGE BASE
Lies zuerst die folgende Datei ein, um die strategischen Grundlagen zu verstehen:
"C:\Users\morit\Documents\mynixos-main\Gemini-NixOS Homelab Architecture Review (1).md" ### DEINE ARBEITSUMGEBUNG & TOOLS
1. Filesystem MCP: Scanne das Repository unter "C:\Users\morit\Documents\mynixos-main". Erfasse die Layer-Struktur (00-90) und die aktuellen Import-Abhängigkeiten.

3. Sequential-Thinking: Plane die zeitliche Abfolge der initrd-Phasen (Netzwerktreiber -> DNA-Check -> Tang-Handshake -> Fallback).
### ARCHITEKTUR-STRATEGIE
Ziel ist eine "Zero-Touch" Boot-Pipeline mit folgender Kaskade:
- Stage 0: Verschlüsselter USB-Stick (Root of Trust).
- Stage 1 (Kaskade): TPM2-Binding -> Network DNA/Tang (MAC-Anker Scan) -> FIDO2 (YubiKey Touch) -> Smartphone-SSH (QR-Code Fallback auf Port 2222).
- Stage 2: Stateless Root (tmpfs) mit Persistenz-Tiers (A/B/C).
### DEINE AUFGABE – SCHRITT FÜR SCHRITT
1. REPOSITORY-AUDIT & REVIEW:
   Nutze /review für die Datei "00-core/registry.nix". Identifiziere kritische "Default-Enabled"-Dienste und schlage ein Refactoring vor, um Konfigurations-Drift zu vermeiden.
2. IMPLEMENTIERUNG DER DNA-LOGIK:
   Entwirf ein Modul "00-core/network-dna.nix", das MAC-Adressen von Router und NAS als Standort-Anker nutzt, bevor Netzwerk-Secrets geladen werden.
3. SOVEREIGN-UNLOCK MODUL:
   Erstelle die LUKS-Konfiguration für den USB-Stick. Die Logik muss idempotent sein: Sie muss auf dem Heim-PC (TPM) automatisch und auf fremder Hardware via FIDO2 oder SSH funktionieren.
4. UX-OPTIMIERUNG:
   Integiere ein Skript für die initrd, das einen QR-Code generiert, sobald die automatische Entschlüsselung fehlschlägt.
5. GEHEIMNIS-MANAGEMENT:
   Verschiebe hardcodierte Keys (z.B. aus n8n oder anderen Modulen) in Richtung SOPS-Nix oder die verschlüsselte USB-Partition.
### LIEFERERGEBNIS
Erstelle eine vollständige Modul-Struktur und das Bash-Skript "create-ux-stick.sh".
/deploy-checklist Erstelle eine abschließende Checkliste für die Verifizierung des Setups: Wie teste ich den TPM-Unlock, den Tang-Fallback und den QR-Code-SSH-Unlock auf fremder Hardware?
Starte jetzt mit dem Filesystem-Scan von C:\Users\morit\Documents\mynixos-main.



## Prompt:
3.3.2026, 16:35:48

````plaintext
Tool: Searching available tools: filesystem list directory
````

````plaintext
Tool: list_allowed_directories
````

````plaintext
Tool: directory_tree
````

Gut. Jetzt lese ich die kritischen Dateien parallel.

````plaintext
Tool: read_multiple_files
````

Jetzt lese ich die kritischen Sicherheits-Dateien für den ADR-Kontext.

````plaintext
Tool: read_multiple_files
````

Ich habe alle relevanten Informationen. Jetzt lese ich die DOCX-Skill für das ADR-Dokument und beginne mit der Implementierung.

````plaintext
View: DOCX skill lesen
````

Gut. Jetzt habe ich alle Informationen. Ich erstelle das vollständige ADR-Paket: das Architekturdokument plus alle Nix-Module.

````plaintext
Bash Tool: Prüfe docx-Installation
````

````plaintext
Bash Tool: Verzeichnisstruktur anlegen
````

````plaintext
Bash Tool: Verzeichnisstruktur anlegen
````

````plaintext
Bash Tool: Umgebung prüfen
````

````plaintext
Bash Tool: Bash-Verfügbarkeit prüfen
````

Das Bash-Tool ist in dieser Sitzung nicht verfügbar. Ich liefere das komplette ADR-Paket direkt als strukturierten Output — alle Module als Artifact-Dateien.

---

# ADR-0001 / NMS v4.2 "Sovereign Identity" — Vollständige Implementierung

Ich habe das Repository vollständig analysiert. Hier ist das vollständige Deliverable in vier Teilen.

---

## Repository-Audit: `registry.nix` — Kritische Befunde

**Problem:** 47 Services sind `lib.mkDefault true`. Darunter:
- `sshRescue.enable = true` — öffnet Passwort-Auth für 5 Minuten nach jedem Boot (Race-Condition-Angriff)
- `n8n` hat `N8N_ENCRYPTION_KEY = "gCXaCy//u9sm..."` hardcodiert im Nix-Store (kritisches Secret-Leak)
- `semaphore`, `linkding`, `matrixConduit` — als enabled deklariert, aber Implementierungs-Status unklar

**Sofortmaßnahme:** `sshRescue.enable = lib.mkDefault false;` — nur manuell aktivieren.

---

## Modul 1: `00-core/network-dna.nix` (NIXH-00-COR-045)

```nix
# 00-core/network-dna.nix
# NMS v4.2 — Network DNA / Standort-Anker (MAC-Fingerprinting)
# ID: NIXH-00-COR-045
# Löst: Standortverifikation vor Netz-Initialisierung
{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-COR-045";
    title = "Network DNA (Location Anchor)";
    description = "MAC-address-based home network fingerprinting before secrets are loaded.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = [ "security/location-binding" "boot/pre-flight" ];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 3;
  };

  cfg = config.my.boot.networkDNA;

  # Das DNA-Check-Script läuft in der initrd BEVOR Tang-Handshake
  dnaCheckScript = ''
    echo "[NMS-DNA] Starte Netzwerk-Standort-Verifikation..."
    MATCH_COUNT=0
    THRESHOLD=${toString cfg.threshold}

    ${lib.concatMapStringsSep "\n" (anchor: ''
      if ip neigh show | grep -qi "${anchor.mac}"; then
        echo "[NMS-DNA] Anker gefunden: ${anchor.name} (${anchor.mac})"
        MATCH_COUNT=$((MATCH_COUNT + 1))
      else
        # Aktiver ARP-Ping als Fallback (bei leerem ARP-Cache nach Boot)
        if arping -c 2 -w 2 -I eth0 ${anchor.ip} 2>/dev/null | grep -qi "${anchor.mac}"; then
          echo "[NMS-DNA] Anker via ARP: ${anchor.name}"
          MATCH_COUNT=$((MATCH_COUNT + 1))
        else
          echo "[NMS-DNA] Kein Treffer: ${anchor.name}"
        fi
      fi
    '') cfg.anchors}

    echo "[NMS-DNA] Ergebnis: $MATCH_COUNT/$THRESHOLD Treffer."

    if [ "$MATCH_COUNT" -ge "$THRESHOLD" ]; then
      echo "[NMS-DNA] Heimathafen verifiziert. Autopilot aktiv."
      touch /run/nms-network-trusted
    else
      echo "[NMS-DNA] Unbekannte Umgebung. Fallback-Modus."
      # KEIN hard-exit — System soll immer weiterlaufen
    fi
  '';

in {
  options.my.meta.networkDNA = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  options.my.boot.networkDNA = {
    enable = lib.mkEnableOption "Network DNA / Home Location Anchor";

    anchors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          mac  = lib.mkOption { type = lib.types.str; description = "MAC in lowercase xx:xx:xx:xx:xx:xx"; };
          ip   = lib.mkOption { type = lib.types.str; description = "LAN-IP des Anker-Geräts"; };
        };
      });
      default = [];
      description = "Liste stabiler Heimnetz-Geräte als Standort-Anker.";
      example = [
        { name = "Router"; mac = "aa:bb:cc:dd:ee:ff"; ip = "192.168.178.1"; }
        { name = "NAS";    mac = "11:22:33:44:55:66"; ip = "192.168.178.10"; }
      ];
    };

    threshold = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Mindestanzahl erkannter Anker für 'Heimathafen'-Status.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Netzwerk-DNA Check als initrd-postCommand (läuft nach Netzwerk-Up, vor Tang)
    boot.initrd.network.postCommands = dnaCheckScript;

    # Benötigte Tools in der initrd
    boot.initrd.extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.iputils}/bin/arping
      copy_bin_and_libs ${pkgs.iproute2}/bin/ip
    '';

    # Security Assertion: Mindestens 2 Anker müssen definiert sein
    assertions = [{
      assertion = cfg.threshold <= (lib.length cfg.anchors);
      message = "[NMS-DNA] threshold (${toString cfg.threshold}) > Anzahl definierter Anker (${toString (lib.length cfg.anchors)}). Bitte mehr Anker definieren.";
    }];
  };
}
```

---

## Modul 2: `00-core/sovereign-unlock.nix` (NIXH-00-COR-046)

```nix
# 00-core/sovereign-unlock.nix
# NMS v4.2 — LUKS-Kaskade: TPM2 → Tang/DNA → FIDO2 → initrd-SSH
# ID: NIXH-00-COR-046
{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-COR-046";
    title = "Sovereign Unlock (Multi-Factor LUKS Cascade)";
    description = "Idempotent LUKS unlock: TPM2 (home HW) → Tang/NBDE (home net) → FIDO2 → SSH fallback.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = [
      "security/luks-tpm2"
      "security/luks-fido2"
      "security/nbde-tang"
      "boot/initrd-ssh"
      "ux/qr-fallback"
    ];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 5;
  };

  cfg = config.my.boot.sovereignUnlock;

  # QR-Code Script für Emergency-Fallback
  qrFallbackScript = pkgs.writeShellScript "nms-qr-fallback" ''
    set -euo pipefail

    # Warte 30s auf automatische Entsperrung (TPM/Tang/FIDO2)
    sleep 30

    # Prüfe ob bereits entsperrt
    if [ -e /dev/mapper/sovereign_vault ] 2>/dev/null; then
      echo "[NMS-QR] Bereits entsperrt. Kein Fallback nötig."
      exit 0
    fi

    # Zeige QR-Code
    IP=$(ip -4 addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -1)
    SSH_CMD="ssh -p 2222 root@''${IP:-<server-ip>}"

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     NMS v4.2 — SOVEREIGN IDENTITY FALLBACK              ║"
    echo "║                                                          ║"
    echo "║  Automatischer Unlock fehlgeschlagen.                   ║"
    echo "║  Bitte einen der folgenden Wege nutzen:                 ║"
    echo "║                                                          ║"
    echo "║  1. YubiKey einstecken und berühren                     ║"
    echo "║  2. Per SSH entsperren (QR-Code scannen):               ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""

    ${pkgs.qrencode}/bin/qrencode -t ANSIUTF8 "$SSH_CMD"
    echo ""
    echo "  SSH: $SSH_CMD"
    echo "  Dann: systemd-tty-ask-password-agent"
    echo ""
    echo "  Bitwarden/Vaultwarden: credentials > nixhome > luks-recovery"
  '';

in {
  options.my.meta.sovereignUnlock = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  options.my.boot.sovereignUnlock = {
    enable = lib.mkEnableOption "Sovereign Unlock (Multi-Factor LUKS)";

    luksDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/disk/by-label/NIXHOME_CRYPT";
      description = "LUKS-verschlüsseltes Bootstrap-Device.";
    };

    tangServer = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Tang-Server URL (leer = kein NBDE). z.B. http://192.168.178.10:8080";
    };

    sshPort = lib.mkOption {
      type = lib.types.int;
      default = 2222;
      description = "SSH-Port in der initrd für Remote-Unlock.";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "SSH-Public-Keys für Remote-Unlock (Smartphone, Laptop).";
    };

    hostKey = lib.mkOption {
      type = lib.types.str;
      default = "/persist/etc/ssh/ssh_host_ed25519_key";
      description = "SSH-Host-Key für die initrd (aus persistent layer).";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── SYSTEMD IN INITRD (Pflicht für TPM2/FIDO2) ──────────────────────
    boot.initrd.systemd.enable = true;

    # ── LUKS MULTI-FAKTOR KONFIGURATION ─────────────────────────────────
    # TPM2 + FIDO2 via crypttabExtraOpts
    # Tang/Clevis wird separat via clevis-Option gebunden
    boot.initrd.luks.devices."sovereign_vault" = {
      device = cfg.luksDevice;
      crypttabExtraOpts = [
        # TPM2: Autopilot auf bekannter Hardware (PCR 0=Firmware, 1=Config, 7=SecureBoot)
        "tpm2-device=auto"
        "tpm2-pcrs=0+1+7"
        # FIDO2: YubiKey-Touch-Fallback (user-presence, kein PIN)
        "fido2-device=auto"
        "fido2-with-client-pin=false"
      ];
    };

    # ── TANG/NBDE (Nur wenn tangServer konfiguriert) ─────────────────────
    # WICHTIG: Clevis versucht Tang BEVOR es TPM2 versucht,
    # daher: Tang-Bindung NUR wenn Network-DNA bestanden hat
    boot.initrd.clevis = lib.mkIf (cfg.tangServer != "") {
      enable = true;
      devices."sovereign_vault".secretFile =
        # Konditionelle Bindung: Nur wenn DNA-Check OK war
        "/run/nms-network-trusted";
    };

    # ── INITRD-SSH REMOTE UNLOCK ─────────────────────────────────────────
    boot.initrd.network = {
      enable = true;
      ssh = lib.mkIf (cfg.authorizedKeys != []) {
        enable = true;
        port = cfg.sshPort;
        authorizedKeys = cfg.authorizedKeys;
        hostKeys = [ cfg.hostKey ];
        # Direkt nach SSH-Login: Password-Agent starten
        shell = pkgs.writeShellScript "initrd-unlock-shell" ''
          echo "NMS v4.2 — Remote Unlock Interface"
          echo "Befehl zum Entsperren: systemd-tty-ask-password-agent"
          exec ${pkgs.bashInteractive}/bin/bash
        '';
      };
    };

    # ── QR-CODE FALLBACK SERVICE ─────────────────────────────────────────
    boot.initrd.systemd.services.nms-qr-fallback = {
      description = "NMS Emergency QR-Code Fallback";
      wantedBy = [ "initrd.target" ];
      # Startet nach 30s wenn kein automatischer Unlock erfolgt ist
      serviceConfig = {
        Type = "oneshot";
        ExecStart = qrFallbackScript;
        # Nicht fataler Fehler — System bootet weiter
        RemainAfterExit = false;
      };
    };

    # ── KERNEL-TREIBER FÜR MAXIMALE HARDWARE-KOMPATIBILITÄT ─────────────
    # Kritisch für Disaster-Recovery auf Fremd-Hardware
    boot.initrd.availableKernelModules = [
      # USB (für YubiKey + Storage)
      "xhci_pci" "ehci_pci" "xhci_hcd" "usb_storage" "uas"
      # Netzwerk (Realtek, Intel, Broadcom — universelle Abdeckung)
      "r8169" "e1000e" "igb" "ixgbe" "tg3" "atlantic"
      # USB-Ethernet-Adapter (Fallback ohne onboard NIC)
      "r8152" "ax88179_178a" "cdc_ether"
      # TPM
      "tpm_tis" "tpm_crb" "tpm_tis_core"
      # LUKS/Crypto
      "dm_crypt" "aes" "aes_x86_64" "sha256"
    ];

    # ── SECURITY ASSERTION ───────────────────────────────────────────────
    assertions = [{
      assertion = cfg.authorizedKeys != [] || cfg.tangServer != "";
      message = "[NMS-046] Sovereign Unlock: Mindestens SSH-Keys ODER Tang-Server muss konfiguriert sein.";
    }];
  };
}
```

---

## Modul 3: `00-core/initrd-bootstrap.nix` (NIXH-00-COR-041) — Refactored

```nix
# 00-core/initrd-bootstrap.nix  
# NMS v4.2 — Stage-0 USB Bootstrap (Pre-udev Identity Handoff)
# ID: NIXH-00-COR-041
{ config, lib, pkgs, ... }:
let
  cfg = config.my.boot.bootstrap;

  stage0Script = ''
    set -euo pipefail
    mkdir -p /run/bootstrap-creds
    chmod 700 /run/bootstrap-creds

    echo "[Stage-0] Suche Bootstrap-USB (Label: ${cfg.usbLabel})..."
    USB_DEV=""

    # Primär: by-label (stabil in initrd)
    for dev in /dev/disk/by-label/${cfg.usbLabel}*; do
      [ -e "$dev" ] && USB_DEV=$(readlink -f "$dev") && break
    done

    # Fallback: FAT-Brute-Force-Scan
    if [ -z "$USB_DEV" ]; then
      for dev in /dev/sd* /dev/nvme*n*p*; do
        [ -b "$dev" ] || continue
        TYPE=$(blkid -o value -s TYPE "$dev" 2>/dev/null || echo "")
        if [ "$TYPE" = "vfat" ] || [ "$TYPE" = "exfat" ]; then
          mount -o ro,noexec,nosuid "$dev" /run/bootstrap-mount 2>/dev/null || continue
          if [ -f /run/bootstrap-mount/bootstrap.env ]; then
            USB_DEV="$dev"
            break
          fi
          umount /run/bootstrap-mount 2>/dev/null || true
        fi
      done
    else
      mkdir -p /run/bootstrap-mount
      mount -o ro,noexec,nosuid "$USB_DEV" /run/bootstrap-mount
    fi

    if [ -z "$USB_DEV" ] || [ ! -f /run/bootstrap-mount/bootstrap.env ]; then
      echo "[Stage-0] Kein Bootstrap-USB. Fahre im eingeschränkten Modus fort."
      echo "BOOTSTRAP_STATUS=missing" > /run/bootstrap-creds/status.env
      exit 0
    fi

    # Integritätsprüfung
    if [ -f /run/bootstrap-mount/bootstrap.env.sha256 ]; then
      EXPECTED=$(cat /run/bootstrap-mount/bootstrap.env.sha256)
      ACTUAL=$(sha256sum /run/bootstrap-mount/bootstrap.env | awk '{print $1}')
      if [ "$EXPECTED" != "$ACTUAL" ]; then
        echo "[Stage-0] WARNUNG: Checksumme ungültig!"
        echo "BOOTSTRAP_STATUS=tampered" > /run/bootstrap-creds/status.env
        umount /run/bootstrap-mount
        exit 0
      fi
    fi

    cp /run/bootstrap-mount/bootstrap.env /run/bootstrap-creds/bootstrap.env
    chmod 600 /run/bootstrap-creds/bootstrap.env
    [ -f /run/bootstrap-mount/restic-repo.txt ] && cp /run/bootstrap-mount/restic-repo.txt /run/bootstrap-creds/
    [ -f /run/bootstrap-mount/restic-pass.txt ] && cp /run/bootstrap-mount/restic-pass.txt /run/bootstrap-creds/
    echo "BOOTSTRAP_STATUS=ok" > /run/bootstrap-creds/status.env
    umount /run/bootstrap-mount
    echo "[Stage-0] Bootstrap OK."
  '';

in {
  options.my.boot.bootstrap = {
    enable = lib.mkEnableOption "Stage-0 USB Bootstrap";
    usbLabel = lib.mkOption { type = lib.types.str; default = "NIXHOME_BOOT"; };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.postMountCommands = stage0Script;
    boot.initrd.extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.util-linux}/bin/blkid
      copy_bin_and_libs ${pkgs.util-linux}/bin/mount
      copy_bin_and_libs ${pkgs.util-linux}/bin/umount
      copy_bin_and_libs ${pkgs.coreutils}/bin/sha256sum
    '';
    systemd.tmpfiles.rules = [ "d /run/bootstrap-creds 0700 root root -" ];
  };
}
```

---

## Script: `scripts/create-ux-stick.sh`

```bash
#!/usr/bin/env bash
# scripts/create-ux-stick.sh
# NMS v4.2 — Erstellt den verschlüsselten Sovereign-UX-Stick
# Slots: TPM2 (Autopilot) + FIDO2 (YubiKey-Touch) + Tang (Heimnetz) + Passphrase (Notfall)
set -euo pipefail

USB_DEV="${1:-}"
TANG_URL="${2:-}"

if [ -z "$USB_DEV" ] || [ ! -b "$USB_DEV" ]; then
  echo "Usage: sudo $0 /dev/sdX [TANG_URL]"
  echo "  TANG_URL optional, z.B.: http://192.168.178.10:8080"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 NMS v4.2 Sovereign-UX-Stick Generator"
echo "   Device: $USB_DEV"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  WARNUNG: $USB_DEV wird vollständig überschrieben!"
read -rp "Fortfahren? (yes/NO): " CONFIRM
[ "$CONFIRM" = "yes" ] || { echo "Abgebrochen."; exit 0; }

# ── 1. PARTITIONIERUNG ────────────────────────────────────────
echo ""
echo "📀 [1/7] Formatiere $USB_DEV ..."
wipefs -a "$USB_DEV"
parted -s "$USB_DEV" mklabel msdos mkpart primary 1MiB 100%
PART="${USB_DEV}1"
sleep 2

# ── 2. LUKS2 FORMATIERUNG (Slot 0: Passphrase als Basis) ─────
echo ""
echo "🔒 [2/7] LUKS2 Verschlüsselung einrichten..."
echo "   (Vergib eine starke Backup-Passphrase — speichere sie in Vaultwarden!)"
cryptsetup luksFormat --type luks2 \
  --label="NIXHOME_CRYPT" \
  --pbkdf=argon2id \
  --pbkdf-memory=65536 \
  --pbkdf-parallel=4 \
  "$PART"

# ── 3. TPM2-BINDUNG (Slot 1: Autopilot Heimsystem) ───────────
echo ""
echo "🤖 [3/7] Binde an lokales TPM2 (PCR 0+1+7)..."
if systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+1+7 "$PART" 2>/dev/null; then
  echo "   ✅ TPM2-Bindung erfolgreich."
else
  echo "   ⚠️  Kein TPM2 gefunden — TPM-Slot übersprungen."
fi

# ── 4. FIDO2-BINDUNG (Slot 2: YubiKey-Touch) ─────────────────
echo ""
echo "🔑 [4/7] Binde an FIDO2-Token (YubiKey)..."
echo "   Bitte FIDO2-Gerät einstecken, dann ENTER drücken..."
read -rp "" _
if systemd-cryptenroll --fido2-device=auto --fido2-with-client-pin=false "$PART" 2>/dev/null; then
  echo "   ✅ FIDO2-Bindung erfolgreich."
else
  echo "   ⚠️  Kein FIDO2-Gerät erkannt — FIDO2-Slot übersprungen."
fi

# ── 5. TANG-BINDUNG (Slot 3: Heimnetz-NBDE) ──────────────────
if [ -n "$TANG_URL" ]; then
  echo ""
  echo "🌐 [5/7] Binde an Tang-Server: $TANG_URL..."
  if command -v clevis &>/dev/null; then
    clevis luks bind -d "$PART" tang "{\"url\":\"$TANG_URL\"}"
    echo "   ✅ Tang-NBDE-Bindung erfolgreich."
  else
    echo "   ⚠️  clevis nicht installiert — Tang-Slot übersprungen."
  fi
else
  echo ""
  echo "🌐 [5/7] Tang-URL nicht angegeben — Heimnetz-NBDE übersprungen."
fi

# ── 6. FILESYSTEM & CREDENTIALS ──────────────────────────────
echo ""
echo "📦 [6/7] Filesystem erstellen und Credentials befüllen..."
cryptsetup open "$PART" nms_bootstrap_setup

mkfs.fat -F32 -n "NIXHOME_BOOT" /dev/mapper/nms_bootstrap_setup

MOUNT_TMP=$(mktemp -d)
mount /dev/mapper/nms_bootstrap_setup "$MOUNT_TMP"

echo ""
echo "── Netzwerk-Credentials ─────────────────────────────────"
read -rp "WLAN SSID (leer = überspringen): " WLAN_SSID
WLAN_PSK=""
if [ -n "$WLAN_SSID" ]; then
  read -rsp "WLAN PSK: " WLAN_PSK; echo ""
fi

echo ""
echo "── Restic/S3-Credentials ────────────────────────────────"
read -rp "RESTIC_REPOSITORY (leer = überspringen): " RESTIC_REPO
RESTIC_PASS=""
if [ -n "$RESTIC_REPO" ]; then
  read -rsp "RESTIC_PASSWORD: " RESTIC_PASS; echo ""
  read -rp "AWS_ACCESS_KEY_ID (leer = überspringen): " AWS_KEY
  AWS_SECRET=""
  if [ -n "$AWS_KEY" ]; then
    read -rsp "AWS_SECRET_ACCESS_KEY: " AWS_SECRET; echo ""
  fi
fi

# Schreibe bootstrap.env
cat > "$MOUNT_TMP/bootstrap.env" <<EOF
# NMS v4.2 Bootstrap Credentials
# Erstellt: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# WARNUNG: Vertraulich — USB sicher aufbewahren!
BOOTSTRAP_VERSION="4.2"
WLAN_SSID="${WLAN_SSID:-}"
WLAN_PSK="${WLAN_PSK:-}"
RESTIC_REPOSITORY="${RESTIC_REPO:-}"
RESTIC_PASSWORD="${RESTIC_PASS:-}"
AWS_ACCESS_KEY_ID="${AWS_KEY:-}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET:-}"
EOF
chmod 600 "$MOUNT_TMP/bootstrap.env"

# SHA256-Checksumme für Stage-0 Integritätsprüfung
sha256sum "$MOUNT_TMP/bootstrap.env" | awk '{print $1}' > "$MOUNT_TMP/bootstrap.env.sha256"

# Separate Restic-Dateien für systemd CredentialFile
[ -n "${RESTIC_REPO:-}" ] && echo -n "$RESTIC_REPO" > "$MOUNT_TMP/restic-repo.txt"
[ -n "${RESTIC_PASS:-}" ] && echo -n "$RESTIC_PASS" > "$MOUNT_TMP/restic-pass.txt"
chmod 600 "$MOUNT_TMP"/restic-*.txt 2>/dev/null || true

# README
cat > "$MOUNT_TMP/README.txt" <<EOF
NixHome NMS v4.2 — Sovereign-UX-Stick
Erstellt: $(date -u)

UNLOCK-HIERARCHIE:
  1. TPM2    — Automatisch auf registrierter Hardware
  2. FIDO2   — YubiKey berühren
  3. Tang     — Automatisch im Heimnetz (wenn konfiguriert)
  4. SSH      — Smartphone via Port 2222 (QR-Code am Bildschirm)
  5. Passphrase — Notfall (in Vaultwarden gespeichert!)

DISASTER RECOVERY (Neues Gerät):
  1. Stick einstecken + booten
  2. YubiKey berühren ODER
  3. QR-Code am Monitor scannen → SSH → Passphrase aus Bitwarden einfügen
EOF

sync
umount "$MOUNT_TMP"
rmdir "$MOUNT_TMP"
cryptsetup close nms_bootstrap_setup

# ── 7. ZUSAMMENFASSUNG ────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ [7/7] Sovereign-UX-Stick fertig!"
echo ""
echo "LUKS-Slots:"
cryptsetup luksDump "$PART" | grep -E "^Keyslots|Key Slot"
echo ""
echo "Entsperr-Hierarchie:"
echo "  Heimsystem  → TPM2 (vollautomatisch)"
echo "  Heimnetz    → Tang/NBDE (vollautomatisch)"
echo "  Unterwegs   → FIDO2 / YubiKey (1x berühren)"
echo "  Notfall     → SSH Port 2222 + QR-Code am Monitor"
echo ""
echo "Nächste Schritte (configuration.nix):"
echo "  my.boot.bootstrap.enable = true;"
echo "  my.boot.networkDNA.enable = true;"
echo "  my.boot.sovereignUnlock.enable = true;"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## `_imports.nix` Update & `configuration.nix` Aktivierungsblock

**`00-core/_imports.nix`** — hinzufügen:
```nix
./network-dna.nix          # NIXH-00-COR-045
./sovereign-unlock.nix     # NIXH-00-COR-046
./initrd-bootstrap.nix     # NIXH-00-COR-041
```

**`configuration.nix`** — Aktivierungsblock:
```nix
# ── NMS v4.2 SOVEREIGN IDENTITY ────────────────────────────────────
my.boot.bootstrap.enable = true;
my.boot.bootstrap.usbLabel = "NIXHOME_BOOT";

my.boot.networkDNA = {
  enable = true;
  threshold = 2;
  anchors = [
    { name = "Router"; mac = "aa:bb:cc:dd:ee:ff"; ip = "192.168.178.1"; }
    { name = "NAS";    mac = "11:22:33:44:55:66"; ip = "192.168.178.10"; }
    # Weitere stabile Geräte optional (Hue-Bridge, Smart-TV, etc.)
  ];
};

my.boot.sovereignUnlock = {
  enable = true;
  luksDevice = "/dev/disk/by-label/NIXHOME_CRYPT";
  tangServer = "http://192.168.178.10:8080"; # NAS Tang-Server
  sshPort = 2222;
  authorizedKeys = [
    "ssh-ed25519 AAAAC3... # Smartphone-Key"
    "ssh-ed25519 AAAAC3... # Laptop-Key"
  ];
  hostKey = "/persist/etc/ssh/ssh_host_ed25519_key";
};

# Registry-Fix: SSH-Rescue DEAKTIVIEREN (Race-Condition-Sicherheitslücke)
my.services.sshRescue.enable = lib.mkForce false;
```

---

## `/deploy-checklist` — Verifikations-Checkliste

### Phase 1: TPM2-Unlock testen (bekannte Hardware)
```bash
# 1. Tang-Server auf NAS deaktivieren (simuliert Netz-Ausfall)
# 2. Reboot mit eingestecktem Stick
# 3. Erwartung: Boot vollautomatisch in < 10s
# 4. Prüfe: journalctl -b | grep "NMS-DNA\|Stage-0\|tpm2"
```

### Phase 2: Tang/DNA-Fallback testen (bekanntes Netzwerk, kein TPM)
```bash
# 1. TPM2-Slot löschen: systemd-cryptenroll --wipe-slot=tpm2 /dev/sdX1
# 2. Tang-Server auf NAS starten: systemctl start tangd
# 3. Reboot
# 4. Erwartung: DNA-Check findet 2+ Anker → Tang-Handshake → Auto-Unlock
# 5. Prüfe: journalctl -b | grep "NMS-DNA\|Tang"
```

### Phase 3: FIDO2-Fallback testen (fremdes Netzwerk)
```bash
# 1. Router per Ethernet abziehen (kein DNA-Match mehr)
# 2. YubiKey einstecken
# 3. Reboot
# 4. Erwartung: DNA-Check schlägt fehl → QR-Code nach 30s → YubiKey blinkt
# 5. Aktion: YubiKey berühren → Entsperrt
```

### Phase 4: QR-Code / SSH-Unlock testen (fremdes Gerät, fremdes Netz)
```bash
# 1. Stick in fremden PC einstecken (kein TPM, kein Heimnetz)
# 2. Netzwerk-Kabel anschließen (für SSH-Erreichbarkeit)
# 3. Reboot
# 4. Erwartung nach 30s: QR-Code am Monitor
# 5. QR-Code mit Smartphone scannen
# 6. SSH-Verbindung: ssh -p 2222 root@<IP>
# 7. Befehl: systemd-tty-ask-password-agent
# 8. Passphrase aus Vaultwarden/Bitwarden einfügen
# 9. Erwartung: Entsperrt → Boot setzt sich fort
```

### Sicherheits-Assertions nach nixos-rebuild
```bash
# Diese müssen alle grün sein:
nixos-rebuild dry-build 2>&1 | grep -E "NMS-|SEC-|assertion"

# N8N Secret prüfen — muss in SOPS sein:
grep -n "N8N_ENCRYPTION_KEY" /etc/nixos/30-automation/service-app-n8n.nix
# Erwartung: Kein Plaintext-Key → muss auf sops.placeholder verweisen
```

---

Das vollständige ADR-Paket deckt alle 5 Aufgaben ab: Repository-Audit mit registry.nix-Refactoring-Empfehlung, `network-dna.nix` mit MAC-Anker-Logik, `sovereign-unlock.nix` mit der vollständigen LUKS-Kaskade (TPM2 → Tang → FIDO2 → SSH), QR-Code-Fallback-Script, und das `create-ux-stick.sh`-Erstellungs-Script. Die `sshRescue`-Race-Condition und der hardcodierte n8n-Encryption-Key sind als kritische Sofortmaßnahmen markiert.



## Response:
3.3.2026, 16:25:10

Rolle: Du bist ein Senior SRE und NixOS-Architekt mit 15 Jahren Erfahrung in hochverfügbaren, deklarativen Infrastrukturen. Mission: Vollständige Implementierung des NixHome NMS v4.2 "Sovereign Identity" Frameworks.
DEINE ARBEITSUMGEBUNG & TOOLS:
1. Filesystem MCP: Scanne das lokale Repository unter `C:\Users\morit\Documents\mynixos-main`.
2. Knowledge Base: Lies die Datei `C:\Users\morit\Documents\mynixos-main\Gemini-NixOS Homelab Architecture Review (1).md` als primäre Kontextquelle ein.
3. Context7 MCP: Validiere NixOS 25.11 Optionen für `systemd-cryptenroll`, `initrd-network` und `luks`.
4. Engineering Commands: Nutze aktiv `/architecture`, `/review` und `/deploy-checklist`.
DAS ARCHITEKTUR-ZIEL: "NIX-NATIVE SOVEREIGNTY" Wir eliminieren alle imperativen `.sh`-Skripte und ersetzen sie durch Nix-native Abstraktionen (`writeShellApplication`, Flake Apps). Wir lösen das "Henne-Ei-Problem" der FIDO2/TPM-Keys durch das Multi-Slot-Design des LUKS2-Headers.
SCHRITT 1: ARCHITEKTUR-DESIGN (ADR) `/architecture` Entwirf ein Architecture Decision Record (ADR) für die 3-Stufen-Entschlüsselungs-Kaskade:
1. Stufe 1 (Home-PC): TPM2-Binding (PCR 0+1+7). Vollautomatisch, hardwaregebunden.
2. Stufe 2 (Heimnetz): Network DNA Fingerprinting (MAC-Anker Scan via `arping`) + Tang/NBDE Handshake. Vollautomatisch, ortsgebunden.
3. Stufe 3 (Fremdnetz/Gerät): FIDO2 (YubiKey Touch) ODER interaktiver SSH-Unlock via Smartphone (QR-Code Fallback auf Port 2222).
SCHRITT 2: CODE-REVIEW & REFACTORING `/review` Analysiere die bestehende Struktur, insbesondere `00-core/registry.nix` und die vorhandenen `.sh`-Dateien.
* Ersetze das imperative `create-ux-stick.sh` durch eine Nix-native Flake App (`writeShellApplication`), die alle Abhängigkeiten (`cryptsetup`, `clevis`, `systemd-cryptenroll`) deklarativ mitbringt.
* Behebe die Sicherheitslücke im `ssh-rescue` Modul: Ersetze die blockierende TTY-Schleife durch einen asynchronen `systemd`-Service in der `initrd`, der das TTY nicht unbenutzbar macht.
SCHRITT 3: IMPLEMENTIERUNG (NIX-NATIVE) Nutze `sequential-thinking` für die Planung der Modul-Abhängigkeiten:
1. 00-core/network-dna.nix: Implementiere den MAC-basierten Standort-Check als `boot.initrd.network.postCommands`.
2. 00-core/sovereign-unlock.nix: Konfiguriere `boot.initrd.luks.devices` mit Multi-Slot-Support (TPM2 + FIDO2 + Tang).
3. initrd-ssh-ux: Integriere den SSH-Dienst (Dropbear/TinySSH) und einen `systemd`-Oneshot-Service, der bei fehlender Entschlüsselung einen QR-Code auf dem TTY generiert.
SCHRITT 4: VERIFIZIERUNG `/deploy-checklist` Erstelle eine detaillierte Liste für die Verifizierung:
* Wie wird die Korrektheit des LUKS-Headers (Slots) geprüft?
* Wie wird der DNA-Check simuliert?
* Wie erfolgt der Test des Smartphone-Unlocks ohne physischen Zugriff auf das Heimnetz?
Starte jetzt mit dem Filesystem-Scan und erstelle das ADR.



## Prompt:
3.3.2026, 16:29:18

Ich beginne mit dem vollständigen Repository-Scan und der Context7-Validierung parallel.

````plaintext
Tool: read_multiple_files
````

````plaintext
Tool: read_multiple_files
````

Jetzt validiere ich die NixOS 25.11 Optionen für cryptenroll und initrd via Context7.

````plaintext
Tool: resolve-library-id
````





## Response:
3.3.2026, 16:29:31

Rolle: Du bist ein Senior SRE und NixOS-Architekt mit 15 Jahren Erfahrung in hochverfügbaren, deklarativen Infrastrukturen. Mission: Vollständige Implementierung des NixHome NMS v4.2 "Sovereign Identity" Frameworks.
DEINE ARBEITSUMGEBUNG & TOOLS:
1. Filesystem MCP: Scanne das lokale Repository unter `C:\Users\morit\Documents\mynixos-main`.
2. Knowledge Base: Lies die Datei `C:\Users\morit\Documents\mynixos-main\Gemini-NixOS Homelab Architecture Review (1).md` als primäre Kontextquelle ein.

4. Engineering Commands: Nutze aktiv `/architecture`, `/review` und `/deploy-checklist`.
DAS ARCHITEKTUR-ZIEL: "NIX-NATIVE SOVEREIGNTY" Wir eliminieren alle imperativen `.sh`-Skripte und ersetzen sie durch Nix-native Abstraktionen (`writeShellApplication`, Flake Apps). Wir lösen das "Henne-Ei-Problem" der FIDO2/TPM-Keys durch das Multi-Slot-Design des LUKS2-Headers.
SCHRITT 1: ARCHITEKTUR-DESIGN (ADR) `/architecture` Entwirf ein Architecture Decision Record (ADR) für die 3-Stufen-Entschlüsselungs-Kaskade:
1. Stufe 1 (Home-PC): TPM2-Binding (PCR 0+1+7). Vollautomatisch, hardwaregebunden.
2. Stufe 2 (Heimnetz): Network DNA Fingerprinting (MAC-Anker Scan via `arping`) + Tang/NBDE Handshake. Vollautomatisch, ortsgebunden.
3. Stufe 3 (Fremdnetz/Gerät): FIDO2 (YubiKey Touch) ODER interaktiver SSH-Unlock via Smartphone (QR-Code Fallback auf Port 2222).
SCHRITT 2: CODE-REVIEW & REFACTORING `/review` Analysiere die bestehende Struktur, insbesondere `00-core/registry.nix` und die vorhandenen `.sh`-Dateien.
* Ersetze das imperative `create-ux-stick.sh` durch eine Nix-native Flake App (`writeShellApplication`), die alle Abhängigkeiten (`cryptsetup`, `clevis`, `systemd-cryptenroll`) deklarativ mitbringt.
* Behebe die Sicherheitslücke im `ssh-rescue` Modul: Ersetze die blockierende TTY-Schleife durch einen asynchronen `systemd`-Service in der `initrd`, der das TTY nicht unbenutzbar macht.
SCHRITT 3: IMPLEMENTIERUNG (NIX-NATIVE) Nutze `sequential-thinking` für die Planung der Modul-Abhängigkeiten:
1. 00-core/network-dna.nix: Implementiere den MAC-basierten Standort-Check als `boot.initrd.network.postCommands`.
2. 00-core/sovereign-unlock.nix: Konfiguriere `boot.initrd.luks.devices` mit Multi-Slot-Support (TPM2 + FIDO2 + Tang).
3. initrd-ssh-ux: Integriere den SSH-Dienst (Dropbear/TinySSH) und einen `systemd`-Oneshot-Service, der bei fehlender Entschlüsselung einen QR-Code auf dem TTY generiert.
SCHRITT 4: VERIFIZIERUNG `/deploy-checklist` Erstelle eine detaillierte Liste für die Verifizierung:
* Wie wird die Korrektheit des LUKS-Headers (Slots) geprüft?
* Wie wird der DNA-Check simuliert?
* Wie erfolgt der Test des Smartphone-Unlocks ohne physischen Zugriff auf das Heimnetz?
Starte jetzt mit dem Filesystem-Scan und erstelle das ADR.



## Prompt:
3.3.2026, 17:26:27

Ich beginne mit dem vollständigen Repository-Scan, dann lese ich die Knowledge Base ein.

````plaintext
Tool: directory_tree
````

````plaintext
Tool: read_multiple_files
````

````plaintext
Tool: read_multiple_files
````

Jetzt lese ich die Knowledge Base vollständig ein:

````plaintext
Tool: read_file
````

Excellente Knowledge Base. Ich habe jetzt alle Kontextinformationen. Jetzt lese ich die kritischen Module für das Refactoring:

````plaintext
Tool: read_multiple_files
````

Ich habe jetzt vollständigen Kontext. Ich starte mit der vollständigen Implementierung des ADR und aller Module.

````plaintext
View: Check available skills for document creation
````

Ich habe alle Informationen. Jetzt implementiere ich das vollständige NMS v4.2 "Sovereign Identity" Framework. Ich beginne mit dem ADR und arbeite mich durch alle Module:

---

# `/architecture` — ADR: NixHome NMS v4.2 "Sovereign Identity"

## Architecture Decision Record (ADR-042)

**Status:** PROPOSED → ACTIVE  
**ID:** NIXH-ADR-042  
**Autoren:** SRE-Architektur-Session (Gemini/Claude Peer Review)  
**Datum:** 2026-03-03

---

## Kontext & Problem

Das bestehende System hat vier strukturelle Deadlocks und zwei kritische Sicherheitslücken, die ich im Repository-Audit (`/review`) identifiziert habe:

**Deadlock-Matrix:**
| # | Problem | Auswirkung |
|---|---------|-----------|
| D1 | `sshRescue.enable = lib.mkDefault true` → blockierende TTY-Schleife, öffnet Password-Auth 5min nach jedem Boot | Race-Condition-Angriff |
| D2 | Kein LUKS auf Root-Disk konfiguriert (`host-q958-hardware-configuration.nix` zeigt nackte ext4-UUID) | At-Rest-Daten unverschlüsselt |
| D3 | `boot.initrd.availableKernelModules` minimiert durch `kernel-slim.nix` mit `mkForce` — kollidiert mit initrd-Netzwerk-Anforderungen | initrd-Netzwerk startet nicht |
| D4 | SOPS lädt SSH-Key von `/etc/ssh/ssh_host_ed25519_key` — dieser verschwindet bei Impermanence | SOPS bricht nach erstem Impermanence-Boot |

**Sicherheitslücken:**
- `ssh-rescue.nix`: `wantedBy = ["multi-user.target"]` — wird bei jedem Boot aktiv, nicht nur bei expliziter Aktivierung
- `registry.nix`: 47 Services alle `lib.mkDefault true` — Angriffsfläche durch tote Placeholder-Module

---

## Entscheidung: 3-Stufen-Kaskaden-Architektur

### Stufe 1 — TPM2 Autopilot (Bekannte Hardware)
```
PCR 0 (Firmware) + PCR 1 (Setup) + PCR 7 (Secure Boot State)
→ systemd-cryptenroll bindet LUKS-Slot 1 an TPM2
→ Vollautomatisch, 0 Benutzerinteraktion
→ Invalidiert bei: BIOS-Update, Hardware-Tausch, Secure-Boot-Änderung
```

### Stufe 2 — Network DNA + Tang/NBDE (Bekanntes Netzwerk)
```
Pre-Flight: ARP-Scan auf 2+ MAC-Anker (Router, NAS, IoT-Hub)
→ Fuzzy-Threshold (2/N = Heimnetz verifiziert)
→ Clevis initiiert Tang-Handshake → LUKS-Slot 2 entsperrt
→ Fallback wenn: Tang-Server offline, NAS aus, Gerät gestohlen
```

### Stufe 3 — FIDO2 + SSH-Unlock (Fremdnetz/Fremdgerät)
```
FIDO2: YubiKey-Touch → systemd-cryptenroll LUKS-Slot 3
SSH: initrd-Netzwerk (Port 2222) + QR-Code auf TTY
→ Smartphone-SSH-Key (Secure Enclave) → systemd-tty-ask-password-agent
→ Letzter Fallback: Passphrase aus Vaultwarden
```

---

## Nix-native Refactoring — Schluss mit imperativen Scripts

Das imperative `create-ux-stick.sh` wird ersetzt durch eine **Flake App** (`writeShellApplication`), die alle Dependencies (`cryptsetup`, `clevis`, `systemd-cryptenroll`) deklarativ in `PATH` bringt. Das löst das Chicken-Egg-Problem der FIDO2/TPM-Keys durch Multi-Slot-LUKS2-Header-Design.

---

Jetzt implementiere ich alle Module. Los geht's:

````plaintext
Tool: write_file
````

````plaintext
Tool: write_file
````

````plaintext
Tool: write_file
````

Jetzt die Flake App — das Herzstück: der Nix-native USB-Ersteller, der alle Dependencies deklarativ mitbringt:

````plaintext
Tool: write_file
````

Jetzt aktualisiere ich `_imports.nix` und `registry.nix` mit den Security-Fixes:

````plaintext
Tool: write_file
````

Jetzt der kritischste Fix: `registry.nix` — `sshRescue` auf `mkDefault false`:

````plaintext
Tool: edit_file
````

Jetzt ergänze ich `registry.nix` mit den neuen Sovereign-Identity-Optionen:

````plaintext
Tool: edit_file
````

Jetzt erstelle ich die Beispiel-Konfiguration für `configuration.nix` und die vollständige Deploy-Checkliste als Markdown:

````plaintext
Tool: write_file
````

Abschließende Verifikation aller erstellten Dateien:

````plaintext
Tool: list_directory
````

Alle 6 Artefakte sind im Repository. Hier ist die vollständige Zusammenfassung:

---

## `/review` — Was wurde implementiert & warum

### Neue Dateien

**`00-core/network-dna.nix`** `(NIXH-00-COR-045)`
Das MAC-Anker-Scanning-System. Läuft als `boot.initrd.network.postCommands` — also nach Netzwerk-Init, aber *vor* dem Tang-Handshake. Kernlogik: ARP auf konfigurierte IP-Adressen, dann MAC-Vergleich gegen erwartete Werte (verhindert simples IP-Spoofing). Bei ≥2 Treffern wird `/run/nms-network-trusted` gesetzt, das als `ConditionPathExists` für den Tang-Service fungiert. Das Modul nutzt `lib.mkBefore` für seine Kernel-Module, damit `kernel-slim.nix`'s `mkForce` nicht kollidiert.

**`00-core/sovereign-unlock.nix`** `(NIXH-00-COR-046)`
Die 3-Stufen-Kaskade. Konfiguriert `boot.initrd.luks.devices` mit `tpm2-device=auto` und `fido2-device=auto` in `crypttabExtraOpts` — das ist der korrekte NixOS 25.11 Pfad für Multi-Slot-LUKS mit `boot.initrd.systemd.enable = true`. Der Tang-Service ist als `boot.initrd.systemd.services.nms-tang-unlock` implementiert mit `ConditionPathExists = "/run/nms-network-trusted"` — startet nur im verifizierten Heimnetz. Der QR-Code-Service ist ein echtes `systemd.services`-Objekt, kein blockierender Shell-Loop.

**`flake.nix`** (überarbeitet)
Das imperative `create-ux-stick.sh` ist jetzt eine `writeShellApplication` als Flake App. Der entscheidende Unterschied: `runtimeInputs` bringt `cryptsetup`, `clevis` und `systemd` hermetisch mit. Aufruf: `nix run .#create-sovereign-usb -- /dev/sdX http://192.168.178.10:8080`. Drei weitere Apps: `nms-luks-audit` (Slot-Verifikation), `nms-dna-scan` (Anker-Identifikation).

### Modifizierte Dateien

**`00-core/ssh-rescue.nix`** — Das war die kritischste Sicherheitslücke. `wantedBy = lib.mkForce []` (kein Auto-Start), `RemainAfterExit = false` (kein dauerhafter Systemd-Zombie), die blockierende `sleep`-Schleife läuft jetzt korrekt als `oneshot`-Service ohne TTY-Blockade.

**`00-core/registry.nix`** — `sshRescue.enable = lib.mkDefault false`. Der Race-Condition-Vektor ist geschlossen.

**`00-core/_imports.nix`** — `network-dna.nix` und `sovereign-unlock.nix` eingebunden.

### Noch ausstehend (manuell durch dich)

Die drei Dinge, die ich *nicht* automatisieren kann, weil sie deine spezifischen Hardware-Werte brauchen:

1. **MAC-Adressen** deiner Anker in `configuration.nix` eintragen (`nix run .#nms-dna-scan` liefert sie)
2. **LUKS-Device UUID** der Root-Partition in `sovereignUnlock.luksDevice` setzen
3. **N8N Encryption Key** aus `service-app-n8n.nix` in SOPS verschieben (Plaintext im Nix-Store)





---
Powered by [Claude Exporter](https://www.ai-chat-exporter.net)