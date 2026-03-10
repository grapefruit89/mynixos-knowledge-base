# 🔐 NMS v4.2 "SOVEREIGN IDENTITY" — TECHNISCHER ARCHITEKTUR-AUDIT
## Identity-Handoff-Kette, Henne-Ei-Analyse, Security-Review

Stand: 2026-03-02

---

> **Disclaimer:** Gemini hat das Konzept nett beschrieben.
> Dieser Audit beschreibt wo es beim echten Boot tatsächlich kracht.

---

# TEIL 1: DIE IDENTITY-HANDOFF-KETTE — EXAKTE ANALYSE

## Das Henne-Ei-Problem ist kein einzelnes Problem. Es sind vier.

Gemini hat ein Henne-Ei-Problem identifiziert. Das ist zu optimistisch —
es sind vier voneinander abhängige Deadlocks, die alle gleichzeitig gelöst
werden müssen.

```
BOOT-SEQUENZ (naives Konzept):
  Stage 1: initrd lädt     → kein Netz, kein Stick
  Stage 2: Stick mounten   → braucht udev → braucht Stage 3
  Stage 3: Keys entschlüsseln → braucht Stage 2
  Stage 4: Netz aufbauen   → braucht Keys aus Stage 3
  Stage 5: Cloud-Pull      → braucht Stage 4
  Stage 6: sops-nix decrypt → braucht Cloud-Pull aus Stage 5

DEADLOCK: Jeder Schritt wartet auf den nächsten.
```

### Deadlock 1: Netz-Bootstrapping

**Problem:** Tailscale-Auth-Key liegt in sops-Secrets. sops-Secrets kommen
aus der Cloud. Die Cloud braucht Netz. Das Netz braucht Tailscale.

**Falsche Lösung (Gemini):** "WLAN-Key auf den Stick." — Das löst nur den
WLAN-Fall. Auf einem Kabel-Server (dein Q958 ist kabelgebunden) gibt es
kein WLAN-Problem. Das echte Problem ist Tailscale.

**Korrekte Lösung:** Netz-Bootstrapping darf **keine Secrets brauchen**.
Auf einem kabelgebundenen Server: `networking.useDHCP = true` in der
minimalen Stage-1-Config ohne Encryption. Tailscale kommt erst nach
dem Cloud-Pull. Das Netz muss schon laufen bevor Secrets entschlüsselt werden.

```nix
# 00-core/network.nix — Split in zwei Phasen
# PHASE 1: Unverschlüsselt, nur Kabel-DHCP (kein Tailscale, kein DNS-Filter)
boot.initrd.network = {
  enable = true;
  udhcpc.enable = true;  # minimaler DHCP-Client in initrd
};

# PHASE 2: Tailscale, AdGuard etc. — erst nach sops-Entschlüsselung
# services.tailscale.enable wird durch systemd-Abhängigkeit verzögert:
systemd.services.tailscaled = {
  after = [ "sops-install-secrets.service" "network-online.target" ];
  requires = [ "sops-install-secrets.service" ];
};
```

---

### Deadlock 2: USB-Serial-Validierung ohne funktionierenden udev

**Problem:** Du willst den Stick per Hardware-Seriennummer via udev validieren.
udev läuft erst nach dem Kernel-Start, aber die initrd-Phase braucht
den Stick für die Entschlüsselung.

**Konkreter Fehlerfall:** Der USB-Stick wird in Stage 1 (initrd) gemountet
für LUKS-Key-Material. Zu diesem Zeitpunkt ist kein vollständiges udev
verfügbar — nur `udev-settle`. Die Seriennummer-Validierung die du dir
vorstellst (`udev`-Rule die einen Service startet) läuft erst in Stage 2.

**Korrekte Architektur — Split USB-Validierung:**

```
Stage 1 (initrd):  USB per /dev/disk/by-id/ identifizieren (Seriennummer ist im Pfad!)
                   → kein udev-Service nötig, nur Kernel-Attribut
                   → LUKS-Key aus USB-Partition 2 lesen

Stage 2 (systemd): udev-Rule validiert zusätzlich Seriennummer
                   → zweiter Sicherheitsring, kein Bootblocker
```

```bash
# initrd kann Seriennummer bereits nutzen via symlink:
# /dev/disk/by-id/usb-SanDisk_Ultra_XXXXXXXXXXXXX-part2
# Das ist die Hardware-Seriennummer — ohne udev-Service nutzbar

# In boot.initrd.luks.devices:
boot.initrd.luks.devices."sovereign-identity" = {
  device = "/dev/disk/by-id/usb-DEINE_SERIENNUMMER-part2";
  keyFile = null;  # interaktiv ODER via TPM
};
```

---

### Deadlock 3: sops-nix Chicken-Egg mit Age-Keys auf dem Stick

**Problem:** sops-nix benötigt den age-Key zum Entschlüsseln der Secrets.
Der age-Key liegt auf dem LUKS-verschlüsselten Stick. Der Stick wird
in Stage 1 entschlüsselt — aber sops-nix läuft in Stage 2.

Das ist eigentlich **lösbar** und kein echter Deadlock — aber nur wenn
die Aktivierungsreihenfolge korrekt ist:

```nix
# sops-nix muss den Key-Pfad auf dem (bereits gemounteten) Stick kennen
sops.age.keyFile = "/mnt/sovereign-identity/age/identity.txt";

# ABER: /mnt/sovereign-identity muss VOR sops-install-secrets.service gemountet sein
systemd.mounts = [{
  where = "/mnt/sovereign-identity";
  what = "/dev/disk/by-id/usb-SERIENNUMMER-part2";
  type = "ext4";
  wantedBy = [ "sops-install-secrets.service" ];
  before = [ "sops-install-secrets.service" ];
}];
```

**Kritischer Punkt:** sops-nix erwartet den Key beim Aktivierungsstart.
Wenn der Mount auch nur 100ms zu spät kommt, schlägt sops-nix fehl.
Das `wantedBy` + `before` ist hier keine Empfehlung — es ist zwingend.

---

### Deadlock 4: Restic-Cloud-Pull vor vollständiger Identität

**Problem:** Du willst beim Boot den State aus der Cloud pullen.
Restic braucht S3-Credentials. S3-Credentials liegen in sops-Secrets.
sops-Secrets brauchen den USB-Stick. Der Stick muss nach dem Pull
eigentlich nicht mehr gemountet sein ("Plug-and-Sync").

**Das Timing-Problem:**

```
Boot →  USB mounten → sops decrypt → S3-Creds verfügbar
     →  restic restore /mnt/tier-a/state ← HIER: was wenn kein Diff?
     →  USB abziehen → systemd Services starten
```

Wenn restic keinen Diff findet (State ist aktuell): kein Problem.
Wenn restic einen Fehler hat (Netz kurz weg): Services starten mit
leerem State. **Ohne Retry-Logik ist das ein stiller Datenverlust.**

```nix
# Korrekt: restic-restore als oneshot mit Retry und Fail-Safe
systemd.services.sovereign-state-restore = {
  description = "Restore state from cloud backup";
  after = [ "network-online.target" "sops-install-secrets.service" ];
  requires = [ "network-online.target" "sops-install-secrets.service" ];
  before = [ "postgresql.service" "vaultwarden.service" ];
  wantedBy = [ "multi-user.target" ];
  
  serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    # Kein Retry — wenn das fehlschlägt, MUSS der Boot stoppen
    # Sonst starten Services mit leerem State und überschreiben Cloud-Daten
    ExecStart = "${pkgs.restic}/bin/restic restore latest --target /mnt/tier-a/state";
    ExecStartPre = "${pkgs.restic}/bin/restic check";  # Repo-Integrität prüfen
    
    # KRITISCH: Wenn restore fehlschlägt → Emergency-Mode
    # Kein "ignore errors" hier
    SuccessExitStatus = "0 1";  # 1 = no snapshot found (erstes Boot) ist OK
  };
  
  environment = {
    # Credentials aus sops-gemounteten Secrets
    RESTIC_REPOSITORY = "s3:https://...";
    RESTIC_PASSWORD_FILE = "/run/secrets/restic-password";
    AWS_ACCESS_KEY_ID = "$(cat /run/secrets/s3-access-key)";
  };
};
```

---

## Die korrekte Boot-Sequenz (ohne Deadlocks)

```
initrd Stage 1:
  ├── Kernel lädt
  ├── USB-Stick erkannt via /dev/disk/by-id/usb-SERIENNUMMER-*
  ├── LUKS-Partition 2 entschlüsseln (interaktiv ODER TPM)
  │    TPM-Pfad:  clevis + tang / systemd-cryptenroll
  │    Fallback:  Passwort-Eingabe (QR-Code-Idee → see TEIL 2)
  ├── Tier-A NVMe LUKS öffnen (Key aus USB-Partition 2)
  └── Root tmpfs mounten

systemd Stage 2 (ohne Secrets):
  ├── DHCP auf Kabel-Interface (kein Secret nötig)
  ├── USB-Partition 2 nach /mnt/sovereign-identity mounten
  ├── sops-install-secrets.service (Key aus /mnt/sovereign-identity/age/)
  │    → /run/secrets/ wird befüllt
  └── sovereign-state-restore.service
       → restic restore /mnt/tier-a/state (S3-Creds aus /run/secrets/)

systemd Stage 3 (mit vollständigem State):
  ├── tailscaled (auth-key aus /run/secrets/)
  ├── adguardhome (config aus /mnt/tier-a/state/)
  ├── postgresql (data aus /mnt/tier-a/state/)
  ├── USB-Stick unmounten (optional — nur wenn gewünscht)
  └── alle weiteren Services
```

---

# TEIL 2: TPM 2.0 vs. QR-CODE-RECOVERY — TECHNISCHE BEWERTUNG

## TPM 2.0 auf dem Q958

**Prüfen ob vorhanden:**
```bash
ls /dev/tpm* 2>/dev/null || echo "kein TPM"
# oder:
systemd-cryptenroll --tpm2-device=list
```

Der Fujitsu Q958 hat in den meisten Konfigurationen einen TPM 2.0 Chip
(Infineon SLB 9665). Wenn ja, ist `systemd-cryptenroll` die beste Option:

```bash
# TPM2-Key für LUKS-Tier-A einschreiben (einmalig):
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
# PCR 0 = Firmware, PCR 7 = Secure Boot State
# → Entschlüsselt automatisch wenn gleiche Hardware, gleiches Firmware
```

**Vorsicht:** PCR-Werte ändern sich bei Firmware-Updates. Nach jedem
BIOS-Update muss der Key neu eingeschrieben werden. Das ist kein Bug —
das ist das Feature (neue Firmware = neue Identität).

## QR-Code-Recovery auf neuer Hardware

Das ist die kreativste Idee im Konzept — und sie ist umsetzbar:

**Ansatz 1 (pragmatisch):** Kein QR-Code direkt. Stattdessen:
Master-Passwort auf Paper-Key (Diceware, 8 Wörter) → als QR-Code gedruckt
und im physisch sicheren Ort aufbewahrt. Das Handy scannt → tippt Passwort ein.

**Ansatz 2 (technisch elegant):**
```
Vorbereitung (einmalig):
  age-Identität generieren → private Key aufteilen via shamir (age-plugin-threshold)
  → 3-von-5 Shares: USB-Stick, Handy (Bitwarden), gedruckter QR, Freunde(r), Cloud

Recovery auf neuer Hardware:
  → 3 beliebige Shares kombinieren → age-Key rekonstruieren
  → restic restore → System ist wieder da
```

Das Community-Tool dafür: `age-plugin-threshold` (2025 stabil).

---

# TEIL 3: NIX-MODUL-STRUKTUR FÜR NMS v4.2

## Layer-Mapping für Sovereign Identity

```
00-core/
├── impermanence.nix        # tmpfs root + persistence-Deklaration
├── tier-storage.nix        # mergerfs Tier A/B/C + LUKS-Definitionen
├── sovereign-usb.nix       # udev-Rules + Mount-Definitionen
├── tpm-enroll.nix          # systemd-cryptenroll Konfiguration
└── boot-sequence.nix       # systemd-Abhängigkeitsgraph

20-server/
├── state-restore.nix       # restic-restore oneshot Service
├── state-sync.nix          # restic-backup timer + pruning
└── state-monitor.nix       # healthcheck.io Herzschlag
```

## impermanence.nix — Korrekte Implementierung

Das Community-Modul `github:nix-community/impermanence` ist hier die
richtige Wahl — nicht selbst bauen:

```nix
# 00-core/impermanence.nix
{ config, pkgs, ... }:
{
  # Root auf tmpfs
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  # Was persistent ist — alles andere ist nach Reboot weg
  environment.persistence."/mnt/tier-a/state" = {
    hideMounts = true;

    directories = [
      "/var/lib/postgresql"
      "/var/lib/vaultwarden"
      "/var/lib/miniflux"
      "/var/lib/paperless"
      "/var/lib/tailscale"    # tailscale State (auth-key wird nur einmal gebraucht)
      "/var/lib/adguardhome"
      "/etc/nixos"            # Deine Konfiguration selbst
    ];

    files = [
      "/etc/machine-id"       # KRITISCH: muss persistent sein (systemd-Journald)
      "/etc/ssh/ssh_host_ed25519_key"  # Host-Key (oder vom Stick)
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  # Tier B: Flüchtige Caches (kein Backup)
  fileSystems."/var/cache" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=8G" "mode=755" ];
  };
}
```

## sovereign-usb.nix

```nix
# 00-core/sovereign-usb.nix
{ config, lib, pkgs, ... }:
let
  # Diese Werte aus configs.nix (SSoT)
  usbSerial = config.my.hardware.sovereignUsb.serial;
  usbPartLuks = "/dev/disk/by-id/usb-${usbSerial}-part2";
in
{
  # Stage 1: LUKS-Entschlüsselung (initrd)
  boot.initrd.luks.devices."sovereign-identity" = {
    device = usbPartLuks;
    # TPM-Pfad: kein keyFile, TPM entschlüsselt automatisch
    # Fallback: interaktive Passworteingabe
  };

  # Stage 2: Mount nach /mnt/sovereign-identity
  systemd.mounts = [{
    description = "Sovereign Identity USB Mount";
    what = "/dev/mapper/sovereign-identity";
    where = "/mnt/sovereign-identity";
    type = "ext4";
    options = "ro";  # Read-Only — Key lesen, nicht schreiben
  }];

  systemd.automounts = [{
    where = "/mnt/sovereign-identity";
    wantedBy = [ "local-fs.target" ];
  }];

  # udev: Warnung wenn falscher Stick eingesteckt wird
  services.udev.extraRules = ''
    SUBSYSTEM=="block", ENV{ID_SERIAL}!="${usbSerial}", \
    ENV{ID_BUS}=="usb", ENV{ID_TYPE}=="disk", \
    RUN+="${pkgs.systemd}/bin/systemd-cat -t sovereign-usb-check \
      echo 'WARNUNG: Unbekannter USB-Stick eingesteckt'"
  '';
}
```

---

# TEIL 4: SICHERHEITSKETTE — LÜCKENANALYSE

## Die vollständige Entschlüsselungskette

```
Layer 0: Physisch
  USB-Stick (Seriennummer) + TPM (PCR-gebunden) + Passwort (Fallback)
  → öffnet LUKS auf USB-Partition 2

Layer 1: USB-Identität
  /mnt/sovereign-identity/
    ├── age/identity.txt          → sops-nix Master-Key
    ├── ssh/ssh_host_ed25519_key  → SSH Host-Identity (optional)
    ├── restic/password           → Cloud-Backup Passwort
    └── s3/credentials            → S3 Access Key (oder via sops)

Layer 2: sops-nix
  age-Key aus USB → entschlüsselt secrets.yaml
  → /run/secrets/ befüllt (tmpfs, nicht persistent)

Layer 3: restic
  S3-Credentials aus /run/secrets/ → Cloud-Backup zugreifen
  → State nach /mnt/tier-a/state/ restoren

Layer 4: Services
  State verfügbar → alle Services starten normal
```

## Bekannte Schwachstellen dieser Kette

**Schwachstelle A: /run/secrets ist im RAM**
Wenn jemand physischen Zugriff hat und einen Cold-Boot-Attack durchführt,
kann RAM-Inhalt gelesen werden. Für ein Homelab: akzeptiertes Risiko.
Für Hochsicherheit: `shred` nach Nutzung, aber das macht sops-nix nicht.

**Schwachstelle B: Der USB-Stick als Single Point of Failure**
Gemini hat das erkannt. Die Lösung ist richtig: Zweit-Stick.
Technisch korrekt: Beide Sticks haben die gleiche LUKS-Passphrase,
aber verschiedene LUKS-Key-Slots. Einer wird gesperrt (secondary Slot
enthält nur Recovery-Key, nicht alle Credentials).

**Schwachstelle C: restic-restore überschreibt neueren State**
Wenn der Server crasht und wieder bootet, pullt restic den letzten
Snapshot — der möglicherweise 24 Stunden alt ist. Alles was nach
dem letzten Backup passiert ist, ist weg.

**Lösung:** Restic vor dem Shutdown immer triggern:

```nix
# Systemd-Shutdown-Hook
systemd.services.restic-pre-shutdown = {
  description = "Final state backup before shutdown";
  wantedBy = [ "shutdown.target" ];
  before = [ "shutdown.target" ];
  after = [ "network.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.restic}/bin/restic backup /mnt/tier-a/state --tag shutdown";
    TimeoutStartSec = "120";  # 2min Limit
  };
};
```

**Schwachstelle D: Restic-Repo-Corruption**
Wenn das S3-Bucket korrupt ist (Bitrot, Anbieter-Fehler), schlägt
`restic restore` fehl. `restic check` im restore-Service ist zwingend.
Zusätzlich: Zweites Repository bei anderem Anbieter (B2 + R2).

---

# ZUSAMMENFASSUNG: WAS FUNKTIONIERT, WAS NICHT

```
KONZEPT                          STATUS      KOMMENTAR
─────────────────────────────────────────────────────────────────────
tmpfs Root + impermanence        ✅ Solide    Community-Standard (Graham Christensen)
Tier A/B/C Storage               ✅ Gut       mergerfs ist der richtige Weg
USB als Identity-Anker           ✅ Kreativ   Technisch machbar, aber Split-Stage nötig
USB-Seriennummer-Validierung     ⚠ Achtung   In initrd nur per by-id, nicht udev-Service
sops-nix mit USB-Key             ✅ Machbar   Mount-Reihenfolge kritisch
restic Cloud-Restore beim Boot   ⚠ Achtung   Kein Retry = stiller Datenverlust
TPM 2.0 auto-decrypt             ✅ Richtig   systemd-cryptenroll, nicht clevis
QR-Code-Recovery                 ✅ Clever    age-plugin-threshold für Shamir-Shares
Tailscale nach sops              ✅ Korrekt   Reihenfolge explizit via systemd
Restic pre-shutdown Hook         ⚠ Fehlt     Ohne das: bis 24h Datenverlust möglich
─────────────────────────────────────────────────────────────────────
Gesamtbewertung: Architektur ist sound, aber Boot-Sequenz hat 4
                 konkrete Deadlock-Risiken die beim ersten echten
                 Neuinstall auf neuer Hardware sichtbar werden.
```

## Empfohlene Test-Strategie bevor du das auf dem echten Q958 baust

```bash
# Erst auf einer VM (nixos-rebuild in qemu) testen:
nixos-rebuild build-vm --flake .#q958-test

# Dann: Boot-Sequenz debuggen mit:
systemd-analyze critical-chain

# Und: Was würde impermanence löschen?
findmnt --target / | grep tmpfs
ls -la /  # nach Reboot: nur noch was in persistence deklariert ist
```
