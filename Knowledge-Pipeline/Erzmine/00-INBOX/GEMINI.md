# GEMINI.md – Die Master-Verfassung (v14.0)
# Status: INTELLIGENT SOVEREIGN ARCHITECTURE | Stand: März 2026
# Supersedes: v13.0, v12.0, v11.0, v10.0, v7.0
# ADR-040:           LAW OF ASSOCIATIVE MINING        – AKTIV
# AKINATOR-PROTOCOL: REQUIREMENTS FIRST               – AKTIV
# TWO-VAULT-LAW:     VPN-VAULT + EXPOSED-VAULT        – AKTIV
# AUTO-BOOTSTRAP:    SPEED-BASED TIER ASSIGNMENT      – AKTIV

---

## PREAMBLE: BETRIEBLICHES GRUNDGESETZ

Dies ist die einzige Quelle der Wahrheit (Single Source of Truth, SSoT) für alle KI-Agenten
(Gemini CLI, Claude) im "mynixos"-Framework. Sie ist KEIN README. Sie ist ein operatives
Grundgesetz. Jede Abweichung ist ein Systemfehler, keine Meinung.

**Authorship:** Mo (Entscheidungsträger) + Claude (Architecture Master) + Gemini CLI (On-Server Execution)
**Evolution:** v7.0 (Pfad-Reinheit) → v10.0 (Hardware) → v11.0 (Portabilität) → v12.0 (UDS+Mining) → v13.0 (Vault-Split-Entwurf) → v14.0 (Intelligenz-Verfassung)
**Archive:** Alle Vorgänger liegen in `/home/Knowledge-Pipeline/oldGeminis/`

---

## 0. SPATIAL MAP: DIE TOPOGRAPHIE DER SOUVERÄNITÄT

Der Agent MUSS die Dateistruktur als Mental Map verinnerlichen, bevor er handelt.
Jede Datei-Operation, die keine Zieladresse aus dieser Map ableitet, ist ein Systemfehler.

### 🏗️ Werkstatt: `/home/Werkstatt/` – Das Skelett (NixOS-Code)

```
/home/Werkstatt/
├── flake.nix               ← Einziger Einstiegspunkt. Flake-pure. Keine <...>-Pfade.
├── flake.lock
├── modules/
│   ├── 00-core/            ← Kritisch: OS stirbt ohne diese Layer
│   │   ├── boot.nix        systemd-boot, UEFI, kein GRUB
│   │   ├── networking.nix  nftables-Basis, Hostname, DNS
│   │   ├── ssh.nix         CIS-Hardened OpenSSH (s. §VII.D)
│   │   ├── users.nix       User-Definitionen, Gruppen (media GID=169)
│   │   ├── secrets.nix     sops-nix Integration, age-Key-Management
│   │   └── storage.nix     ZFS-Pool, Disk-Label-Mounts, MergerFS (s. §V)
│   ├── 20-server/          ← Kritisch: Server nicht erreichbar ohne diese
│   │   ├── caddy.nix       Reverse-Proxy, UDS-Backend-Policy (s. §VII.B)
│   │   ├── adguard.nix     DNS-Resolver + Ad-Blocker
│   │   ├── tailscale.nix   Zero-Config VPN / Remote-Access
│   │   ├── cloudflared.nix Tunnel für öffentliche Exposition
│   │   ├── postgresql.nix  DB-Backend für alle Dienste
│   │   ├── valkey.nix      KV-Cache (Redis: VERBOTEN)
│   │   └── pocket-id.nix   OIDC-Provider (UDS, Passkey-Only)
│   ├── 30-services/        ← Betriebskritisch, täglich genutzt
│   │   ├── vaultwarden.nix
│   │   ├── n8n.nix
│   │   ├── home-assistant.nix
│   │   ├── matrix-conduit.nix
│   │   ├── semaphore.nix
│   │   ├── homepage.nix
│   │   └── olivetin.nix    First-Run-Dashboard
│   ├── 40-media/           ← Die Aquarien (Container-isoliert, s. §VIII)
│   │   ├── vault-vpn.nix   VAULT-VPN: Prowlarr + SABnzbd (Kill-Switch)
│   │   ├── vault-exposed.nix VAULT-EXPOSED: Jellyfin + ABS (Internet-facing)
│   │   ├── sonarr.nix      Im VAULT-EXPOSED (Aquarium)
│   │   ├── radarr.nix      Im VAULT-EXPOSED (Aquarium)
│   │   ├── jellyseerr.nix
│   │   └── recyclarr.nix
│   ├── 50-knowledge/       ← Wissens- & Dokumenten-Management
│   │   ├── paperless.nix
│   │   ├── miniflux.nix
│   │   ├── readeck.nix
│   │   ├── linkding.nix
│   │   └── karakeep.nix
│   ├── 80-monitoring/      ← Observability
│   │   ├── scrutiny.nix    S.M.A.R.T.-Überwachung (alle Disks)
│   │   ├── netdata.nix     System-Metriken
│   │   └── uptime-kuma.nix Service-Verfügbarkeit
│   └── 90-policy/          ← Build-Zeit-Assertions (kein Laufzeit-Effekt)
│       ├── port-registry.nix Port-Kollisions-Guard
│       ├── container-ban.nix Assertion: Kein Docker/Podman
│       └── lint.nix          Architektur-Regeln
└── hosts/
    └── q958.nix            Maschinenspezifische Overrides (informativ, nicht normativ)
```

**Layer-Einbahnstraße (kein Zirkel-Bezug erlaubt):**
```
00-core ← 20-server ← 30-services ← 40-media ← 50-knowledge ← 80-monitoring ← 90-policy
```
Höhere Layer importieren niedrigere. Niemals umgekehrt.

### 📚 Knowledge-Pipeline: `/home/Knowledge-Pipeline/` – Das Gehirn

```
/home/Knowledge-Pipeline/
├── Almanach/               ← STAGE 2: Veredeltes Wissen, SSoT für ADRs & Guides
├── Erzmine/                ← STAGE 1: Rohdaten-Pipeline (ungeschmolzenes Golderz)
│   ├── 00-INBOX/           Landezone für Chatlogs, Funde, Clipboard-Dumps
│   ├── 01-PROCESSING/      Aktive Mining-Zone (wird aktiv bearbeitet)
│   └── 02-ARCHIVE/         Verifiziertes Archiv & Versions-Historie
│       ├── snapshots/      Einmalige Zustandsaufnahmen
│       └── versions/       Archivierte GEMINI.md-Versionen (v7-v13)
├── .vectorstore/           RAG-Index (LanceDB, lokal-first)
├── oldGeminis/             ← Historisches Museum (v7.0–v13.0), read-only Audit-Trail
└── raw/
    └── sources/            Pattern-Mining Output (GitHub-Repos)
```

---

## I. DER VEREDELUNGS-ZYKLUS: DIE DREI STUFEN DES GOLDES

Wissen wird in diesem System NIEMALS gelöscht. Es durchläuft drei Reifestufen.
Refaktorierung passiert IMMER in separaten Zielordnern – die Quelle bleibt unberührt.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 1: ROH-ERZ (Erzmine)                                                 │
│  Ort:     /home/Knowledge-Pipeline/Erzmine/00-INBOX/                        │
│  Inhalt:  Unsortierte Chat-Exports, Logs, Snippets, Ideen                   │
│  Regel:   NIEMALS löschen. Mit Stage-Tag und ID versehen.                   │
│  Header:  # [META] Stage: 1 | ID: ERZ-<datum>-<kurzbeschreibung>           │
│  Trigger: Neues Material kommt immer hier rein, niemals direkt in Almanach  │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │ Mining & Strukturierung
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 2: NUGGETS (Almanach)                                                │
│  Ort:     /home/Knowledge-Pipeline/Almanach/                                │
│  Inhalt:  Strukturierte ADRs, technische Guides, Service-Dokumentation      │
│  Regel:   Drei-Layer-Standard (KISS / Technical / Reasoning). SSoT.        │
│  Header:  # [META] Stage: 2 | ID: ADR-<NNN> | Version: <X.X>              │
│  Trigger: Sobald Roh-Erz zu einer klaren Entscheidung oder Anleitung wird   │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │ Synthese & Vernetzung
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 3: GOLDBARREN (Refactored Almanach)                                  │
│  Ort:     /home/Knowledge-Pipeline/Almanach/synthesized/ (separater Ordner) │
│  Inhalt:  Verknüpfte System-Gesamtdokumentation, cross-referenced           │
│  Regel:   Entsteht NICHT durch Überschreiben, sondern in neuem Zielordner   │
│  Header:  # [META] Stage: 3 | ID: SYN-<NNN> | Version: <X.X>              │
│  Endziel: Gesamtsystem-Beschreibung als navigierbare Wissensbasis           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Goldschmelz-Checkliste (Stage 1 → Stage 2)

Ein Roh-Erz-Fragment ist reif für den Almanach, wenn:
- [ ] Es eine eindeutige technische Entscheidung beschreibt (nicht nur Idee/Frage)
- [ ] Es einen Kontext hat (Warum? Was wurde verworfen?)
- [ ] Es auf mindestens einen Nix-Modul-Pfad oder ein ADR verweist
- [ ] Es keinen Widerspruch zu einer bestehenden Verfassungsregel enthält
- [ ] Es mit dem Drei-Layer-Standard (KISS / Technical / Reasoning) aufbereitet ist

---

## II. DER METADATEN-HEADER: DAS VERSIONS-GESETZ

Jede `.nix`-Datei in `/home/Werkstatt/` MUSS mit diesem Header beginnen.
Der Header ist ein **reiner Nix-Kommentar**. Er blockiert NIEMALS den Build-Prozess.
Er ist ausschließlich informationsarchitektonisches Hilfsmittel.

```nix
# [META] ID: <ID> | ADR: <ADR-Referenz> | Version: <X.X> | Stage: <1-3>
```

**Pflichtfelder:**

| Feld      | Beschreibung                                          | Beispiel                  |
|-----------|-------------------------------------------------------|---------------------------|
| `ID`      | Eindeutige Modul-ID nach Schema NIXH-LAYER-NNN        | `NIXH-40-MEDIA-001`       |
| `ADR`     | Referenz zum zugehörigen Architecture Decision Record  | `ADR-009`                 |
| `Version` | Dezimalversion, startet bei 1.0                       | `1.3`                     |
| `Stage`   | Reifegrad des Wissens (1=Roh, 2=Nugget, 3=Gold)       | `2`                       |

**Das Versions-Gesetz:**
- Jede inhaltliche Änderung an einer `.nix`-Datei → Version um **+0.1** hochzählen
- Version ist informativ, NICHT der Build-Graph. Kein `assert` auf Version.
- Das Versionssystem ist ein **Informations-Audit**, kein Blocker.

**Beispiel-Header (vollständig):**
```nix
# [META] ID: NIXH-40-MEDIA-001 | ADR: ADR-009 | Version: 1.2 | Stage: 2
# Beschreibung: VAULT-EXPOSED Container für Jellyfin + Audiobookshelf
# Letzte Änderung: 2026-03-10 | Geändert durch: Claude (Architecture Master)
{ config, pkgs, lib, ... }:
{
  # ... Modulinhalt ...
}
```

**Header-Audit-Skript (auslesen ohne Build):**
```bash
#!/usr/bin/env bash
# Liest alle [META]-Header der Werkstatt und gibt Status-Map aus
find /home/Werkstatt -name "*.nix" | while read -r f; do
  header=$(grep -m1 '\[META\]' "$f" 2>/dev/null || echo "[META] ID: MISSING | ADR: MISSING | Version: 0.0 | Stage: 0")
  printf "%-60s %s\n" "$f" "$header"
done | sort
```

---

## III. DER AKINATOR-MODUS: DAS LASTENHEFT-GESETZ

**Das fundamentale Verbot:** Wenn ein Ziel vage oder technisch unspezifiziert ist,
ist das Schreiben von Nix-Code STRIKT VERBOTEN. Kein Raten, kein "Ich mache mal einen Entwurf".

### Das Protokoll

```
EINGEHENDE ANFRAGE
        │
        ▼
Ist das Ziel vollständig spezifiziert?
        │
   JA ──┼──► Direkt implementieren
        │
   NEIN ▼
AKINATOR-MODUS AKTIVIEREN
        │
        ▼
Schritt 1: Frage-Batch 1 (3 Fragen)
        │   → Grundlegende Anforderungen (Was? Warum? Wie groß?)
        ▼
Schritt 2: Antworten protokollieren
        │
        ▼
Schritt 3: Frage-Batch 2 (3 Fragen)
        │   → Technische Constraints (Isolation? Performance? Sicherheit?)
        ▼
Schritt 4: Antworten protokollieren
        │
        ▼
Schritt 5: Lastenheft-Zusammenfassung vorlegen
        │   → Mo bestätigt oder korrigiert
        ▼
Schritt 6: Implementierung beginnt
```

### Akinator-Fragen-Template

```
Batch N: [THEMA]

Frage X: [Frage zu Funktionalität / Verhalten]
Frage Y: [Frage zu Sicherheit / Isolation]
Frage Z: [Frage zu Persistenz / Portabilität]
```

### Was aus dem Akinator-Verhör bereits entschieden wurde (Lastenheft-Stand März 2026)

| Entscheidung | Antwort | Kodifiziert in |
|-------------|---------|----------------|
| Auto-Tiering: Einzige NVMe 4TB | Tier A + B logisch (ZFS-Datasets) | §IV.A |
| Auto-Tiering: Einzige SATA-SSD 4TB | Tier A + B logisch (keine HDD = kein C) | §IV.A |
| B→C Migration Trigger (hoch) | 95% Füllstand auf DISK_CACHE = Forced | §IV.C |
| B→C Migration Trigger (opportunistisch) | 80-85% + Tier C bereits im Spin-up | §IV.C |
| B→C Ziel-Füllstand nach Migration | 70% auf DISK_CACHE | §IV.C |
| Pre-Commit-Hook | NEIN – informativer Header-Guardian, kein Blocker | §II |
| Media-Stack Architektur | Zwei getrennte Container (Vault-VPN + Vault-Exposed) | §VIII |
| Interner Netzwerk-Horror | KISS: Servarrs sehen sich intern frei | §VIII |
| Header-Versionierung | +0.1 pro Touch, dezimal, informativ | §II |
| Redis-Ersatz | Valkey (VERBOTEN: Redis) | §I (NICHT-ZIELE) |

---

## IV. INTELLIGENTES STORAGE: AUTO-BOOTSTRAP & TIER-MANAGEMENT

### A. Auto-Bootstrap: Geschwindigkeitsbasierte Tier-Zuweisung

Das System erkennt beim Erststart automatisch die Speicherklasse jedes Datenträgers
anhand seiner sequenziellen Lese-/Schreibgeschwindigkeit und weist ihm eine Tier-Rolle zu.
**HDD als Tier-A-Gerät ist absolut verboten.** OS-Daten landen niemals auf einer HDD.

```
GESCHWINDIGKEIT       MEDIUM           TIER-ROLLE        LABEL
───────────────────────────────────────────────────────────────────────
> 1.000 MB/s          NVMe M.2/PCIe    A (System/State)  DISK_SYSTEM
~ 400–1.000 MB/s      SATA SSD         B (Cache)         DISK_CACHE
< 200 MB/s / Spinning HDD SATA/USB     C (Bulk)          DISK_STORAGE_*
───────────────────────────────────────────────────────────────────────
HARTES GESETZ: Tier A darf NIEMALS auf HDD (<200 MB/s) liegen.
```

**Single-Drive-Szenarien (Akinator-Entscheid):**

| Hardware-Situation | Tier-Verhalten |
|---|---|
| 1x NVMe (beliebige Größe) | Tier A + B verschmelzen: ein ZFS-Pool, getrennte Datasets |
| 1x SATA SSD (beliebige Größe) | Tier A + B verschmelzen: ein ZFS-Pool, getrennte Datasets |
| 1x HDD | **VERBOTEN** als einziges Medium. Kein OS-Betrieb. |
| 2x NVMe | Tier A = schnellere/größere NVMe; Tier B = zweite NVMe |
| NVMe + SATA SSD | Tier A = NVMe; Tier B = SATA SSD |
| NVMe + SATA SSD + HDD(s) | Tier A = NVMe; Tier B = SSD; Tier C = HDDs (JBOD) |
| 2x NVMe + HDDs | Tier A = beide NVMes (ZFS-Mirror oder separate); Tier C = HDDs |

### B. Die Drei Tiers (Label-Standard, Hardware-Agnostisch)

```
┌──────────────────────────────────────────────────────────────────────────┐
│ TIER A: DISK_SYSTEM                                                      │
│   Medium:     NVMe (> 1 GB/s)                                           │
│   Filesystem: ZFS (rpool)                                                │
│   Datasets:   rpool/local/nix    – Nix Store (ephemer, kein Backup nötig)│
│               rpool/local/root   – Root (ephemer mit tmpfs Overlay)      │
│               rpool/safe/home    – /home (persistent)                    │
│               rpool/safe/persist – /persist (Secrets, DBs, Config)      │
│   Labeling:   ZFS-Pool-Device via /dev/disk/by-id/<nvme-id>             │
│   Portabilität: Jedes NVMe mit korrektem ZFS-Pool                       │
├──────────────────────────────────────────────────────────────────────────┤
│ TIER B: DISK_CACHE                                                       │
│   Medium:     SATA SSD (~ 400–1000 MB/s)                                │
│   Filesystem: ext4                                                        │
│   Inhalt:     SABnzbd-Downloads, Transcoding-Temp, Staging               │
│   Labeling:   e2label /dev/<device> DISK_CACHE                          │
│   Portabilität: Beliebiges SSD/NVMe, korrekt gelabelt                   │
│   SINGLE-DRIVE: Bei fehlendem DISK_CACHE-Gerät → ZFS-Dataset auf Tier A │
├──────────────────────────────────────────────────────────────────────────┤
│ TIER C: DISK_STORAGE_01, DISK_STORAGE_02, ...                           │
│   Medium:     HDD SATA (< 200 MB/s, Spinning = true)                   │
│   Filesystem: ext4 (JBOD, kein RAID, kein Stripping)                    │
│   Inhalt:     Bulk-Media (Jellyfin-Bibliothek), Langzeit-Archiv          │
│   Aggregation: MergerFS-Pool → /mnt/media                               │
│   Labeling:   e2label /dev/<device> DISK_STORAGE_01                    │
│   Portabilität: Beliebige SATA/USB-HDDs, korrekt gelabelt               │
│   OPTIONAL:   Entfällt komplett bei Single-Drive-Systemen               │
└──────────────────────────────────────────────────────────────────────────┘
```

### C. Das Schwellwert-Gesetz: Opportunistische Migration (Tier B → C)

Dies ist die intelligente Daten-Aging-Logik. **Kein starrer Timer, sondern kontextbewusstes Handeln.**

```
FÜLLSTAND DISK_CACHE (TIER B)    TIER C STATUS          AKTION
─────────────────────────────────────────────────────────────────────────
< 80%                             egal                   Keine Aktion
80% – 85%                         INAKTIV (Spin-down)    Keine Aktion (HDD schläft)
80% – 85%                         AKTIV (Spin-up)        OPPORTUNISTISCHE MIGRATION
                                                         Älteste Daten zuerst
                                                         Ziel: B auf 70% entleeren
> 95%                             egal                   FORCED MIGRATION
                                                         Sofort (oder beim nächsten
                                                         systemd-Timer-Lauf nachts)
                                                         Ziel: B auf 70% entleeren
```

**Priorität bei Forced Migration (> 95%):**
1. Größte Dateien zuerst (maximale Platz-Rückgewinnung pro Verschiebevorgang)
2. Älteste Access-Time (am längsten nicht zugegriffen)
3. Zielmedium: MergerFS epmfs wählt DISK_STORAGE_* mit meistem freiem Platz

**Systemd-Timer für Nacht-Migration:**
```nix
# 00-core/storage.nix – Migration-Timer (nicht-blockierend)
systemd.services."tier-migration" = {
  description = "Opportunistic Tier B→C Data Migration";
  serviceConfig = {
    Type            = "oneshot";
    ExecStart       = "/run/current-system/sw/bin/tier-migrate.sh";
    User            = "root";
    Nice            = 19;          # Niedrigste CPU-Priorität
    IOSchedulingClass = "idle";    # Nur idle I/O
  };
};

systemd.timers."tier-migration" = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar  = "03:00";         # Nachts um 3 Uhr
    RandomizedDelaySec = "30min";  # Zufällige Verteilung
    Persistent  = true;
  };
};
```

### D. MergerFS: Das Atomizitäts-Mandat (vollständig)

```nix
# 00-core/storage.nix – MergerFS-Mount
fileSystems."/mnt/media" = {
  device  = "/mnt/storage/01:/mnt/storage/02";  # Erweiterbar: :/mnt/storage/03
  fsType  = "fuse.mergerfs";
  options = [
    "category.create=epmfs"     # PFLICHT: Atomic-Move-Kompatibilität (epmfs = Existing Path Most Free Space)
    "func.getattr=newest"       # PFLICHT: Korrekte Metadaten bei verteilten Dateien
    "ignore_pp=true"            # PFLICHT: Path-Preservation-Overhead deaktivieren
    "allow_other=true"          # PFLICHT: Jellyfin/Sonarr/Radarr-Zugriff als non-root
    "use_ino=true"              # Konsistente Inode-Nummern über alle Branches
    "dropcacheonclose=true"     # Verhindert Inode-Cache-Korruption bei großen Bibliotheken
    "nonempty"                  # Mount auch wenn /mnt/media bereits Dateien hat
    "lazy_umount"               # Graceful Unmount auch bei offenem File-Handle
    "nofail"                    # Boot schlägt nicht fehl wenn eine DISK_STORAGE fehlt
  ];
  depends = [ "/mnt/storage/01" "/mnt/storage/02" ];
};

# Media-Gruppe (GID 169 – Konvention aus mynixos-Legacy, beibehalten für Konsistenz)
users.groups.media = {
  gid     = 169;
  members = [ "jellyfin" "sonarr" "radarr" "sabnzbd" "prowlarr" "audiobookshelf" ];
};
```

### E. Das Atomic-Move-Protokoll

```
KORREKTE PIPELINE (Zero-Copy):
  1. SABnzbd Download  → /mnt/cache/staging/sabnzbd/complete/<datei>    (DISK_CACHE)
  2. Post-Processing   → Umbenennen/Sortieren in /mnt/cache/staging/
  3. Atomic Move       → mv /mnt/cache/staging/<datei> /mnt/media/<ziel>/
     (MergerFS epmfs → wählt DISK_STORAGE mit meistem freiem Platz auf existierendem Pfad)
     (mv = rename() syscall, da MergerFS das auf die eine physische Ziel-HDD routet → O(1))

VERBOTENE PIPELINE (Datei-Copy, langsam, nicht-atomisch):
  1. SABnzbd Download  → /tmp/<datei>              (Tmpfs – andere physische Platte!)
  2. cp/rsync          → /mnt/media/<ziel>/         (Blockierender Kernel-Copy-Pfad)
```

### F. No-RAID/No-Stripping-Mandat (absolut)

```
VERBOTEN: mdadm, SnapRAID, ZFS-RAID, ZFS-Mirror auf Tier C, dm-stripe
BEGRÜNDUNG:
  1. Energie:    RAID erfordert alle Platten gleichzeitig aktiv → kein Spindown möglich
  2. Kapazität:  RAID verbraucht 20–50% Nutzkapazität
  3. Sicherheit: RAID ≠ Backup. Ransomware löscht alle Mirror-Kopien gleichzeitig.
  4. Komplexität: JBOD via MergerFS ist wartungsärmer und KISS-konform.

ERLAUBTE REDUNDANZ:
  → Restic → Cloudflare R2 oder Backblaze B2 (verschlüsselt, off-site, Priorität!)
  → Sanoid (ZFS-Snapshots lokal, schnelle Recovery auf Tier A)
  → Manuelle Kopie auf externe HDD (physischer Notfall-Restore)
```

### G. ZFS-Konfiguration auf Tier A (vollständig)

```nix
# 00-core/storage.nix – ZFS Tier A
boot.supportedFilesystems = [ "zfs" ];
networking.hostId = "XXXXXXXX";  # Aus sops: eindeutige 8-Hex-Zeichen pro Host

services.zfs = {
  autoScrub.enable   = true;
  autoScrub.interval = "weekly";     # Systemd-Timer, sonntags
  trim.enable        = true;         # TRIM für NVMe/SSD
};

boot.kernelParams = [
  "zfs.zfs_arc_max=4294967296"      # ARC-Limit: 4GB (= RAM/4 bei 16GB)
];

# ZFS-Datasets (Imperative Bootstrapping, einmalig beim Erstsetup)
# zpool create -o ashift=12 rpool /dev/disk/by-id/<nvme-id>
# zfs create -o mountpoint=none rpool/local
# zfs create -o mountpoint=/nix rpool/local/nix
# zfs create -o mountpoint=none rpool/safe
# zfs create -o mountpoint=/home rpool/safe/home
# zfs create -o mountpoint=/persist rpool/safe/persist

# ZFS Dataset-Properties (deklarativ via NixOS nicht möglich, einmalig imperativ setzen):
# zfs set compression=lz4 rpool
# zfs set atime=off rpool/local/nix
# zfs set xattr=sa rpool/safe/persist
```

---

## V. SICHERHEITSARCHITEKTUR: DAS ZWEI-VAULT-MODELL

Dies ist der Kern der Media-Isolation. Das historische "Aquarium" ist aufgeteilt in zwei
klar getrennte NixOS-Container (systemd-nspawn), jeder mit eigenem Sicherheitsprofil.

### Das Gesetz der Zwei Tresore

```
┌─────────────────────────────────────────────────────────────────┐
│  HOST                                                           │
│  ┌───────────────┐    UDS-Socket    ┌──────────────────────┐   │
│  │  Caddy        │◄────────────────►│  VAULT-VPN           │   │
│  │  (Host-Proxy) │                  │  Prowlarr + SABnzbd  │   │
│  │               │    UDS-Socket    │  privateNetwork=true  │   │
│  │               │◄────────────────►│  wg-privado only     │   │
│  │               │                  │  Kill-Switch aktiv   │   │
│  │               │                  └──────────────────────┘   │
│  │               │                                             │
│  │               │    UDS-Socket    ┌──────────────────────┐   │
│  │               │◄────────────────►│  VAULT-EXPOSED       │   │
│  │               │                  │  Jellyfin + ABS      │   │
│  └───────────────┘                  │  Radarr + Sonarr     │   │
│                                     │  privateNetwork=true  │   │
│                                     │  kein VPN-Zwang       │   │
│                                     │  Internet-Hardening  │   │
│                                     └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### A. VAULT-VPN: Der Hochsicherheitstrakt

Zweck: Dienste, die aktiv ins Internet kommunizieren und dabei ihre IP verbergen MÜSSEN.
Enthält: Prowlarr (Indexer-Suche), SABnzbd (Downloads)

```nix
# [META] ID: NIXH-40-MEDIA-002 | ADR: ADR-011 | Version: 1.0 | Stage: 2
# 40-media/vault-vpn.nix
{ config, pkgs, lib, ... }:
{
  containers."vault-vpn" = {
    autoStart      = true;
    privateNetwork = true;          # PFLICHT: Absoluter Kill-Switch
    hostBridge     = "br-vpn";      # Hardware-agnostische Bridge

    # VPN Kill-Switch: NUR wg-privado-Interface im Container sichtbar
    # Ohne aktives wg-privado → kein Netzwerk-Escape möglich (Leak-Protection)
    interfaces     = [ "wg-privado" ];

    # UDS-Sockets für Caddy-Kommunikation (Host → Container)
    # Mountet /run/caddy-vpn auf Host in /run/caddy im Container
    bindMounts = {
      "/run/caddy" = {
        hostPath   = "/run/caddy-vpn";
        isReadOnly = false;
      };
      # Persistente Daten auf ZFS /persist
      "/var/lib/prowlarr" = {
        hostPath   = "/persist/prowlarr";
        isReadOnly = false;
      };
      "/var/lib/sabnzbd" = {
        hostPath   = "/persist/sabnzbd";
        isReadOnly = false;
      };
      # Download-Staging auf DISK_CACHE (Tier B) für Atomic Moves
      "/mnt/cache/staging" = {
        hostPath   = "/mnt/cache/staging";
        isReadOnly = false;
      };
    };

    config = { pkgs, ... }: {
      services.prowlarr = {
        enable   = true;
        # Prowlarr lauscht auf UDS-Socket (kein TCP)
        # Konfiguration via prowlarr.xml: <BindAddress>unix:/run/caddy/prowlarr.sock</BindAddress>
      };

      services.sabnzbd = {
        enable = true;
        # SABnzbd: Temp-Download-Ordner = /mnt/cache/staging/sabnzbd
        # Complete-Download-Ordner   = /mnt/cache/staging/complete
        # Konfiguration via sabnzbd.ini: host_whitelist = ...
      };

      # nftables Kill-Switch innerhalb des Containers
      networking.nftables.ruleset = ''
        table inet vpn-killswitch {
          chain output {
            type filter hook output priority 0; policy drop;
            oifname "lo"         accept
            oifname "wg-privado" accept
            # ALLES andere wird gedroppt – kein Leak möglich
          }
        }
      '';
    };
  };

  # Host-Bridge für VAULT-VPN
  networking.bridges."br-vpn".interfaces = [];
  networking.interfaces."br-vpn".ipv4.addresses = [{
    address      = "10.100.1.1";
    prefixLength = 24;
  }];

  # Socket-Verzeichnisse auf Host
  systemd.tmpfiles.rules = [
    "d /run/caddy-vpn 0750 caddy caddy -"
  ];
}
```

### B. VAULT-EXPOSED: Die Festung (Internet-Facing)

Zweck: Dienste, die direkt aus dem Internet erreichbar sein müssen (kein Cloudflare-Tunnel möglich).
Enthält: Jellyfin (kein Cloudflare-Proxy erlaubt wegen ToS), Audiobookshelf, Radarr, Sonarr

**KISS-Prinzip (Akinator-Entscheid):** Radarr und Sonarr sehen sich innerhalb des Vaults frei.
Kein internes UDS-Netz zwischen den Aquarium-Bewohnern. Nur der Ingress (Caddy) kommuniziert via UDS.

```nix
# [META] ID: NIXH-40-MEDIA-003 | ADR: ADR-012 | Version: 1.0 | Stage: 2
# 40-media/vault-exposed.nix
{ config, pkgs, lib, ... }:
{
  containers."vault-exposed" = {
    autoStart      = true;
    privateNetwork = true;          # Isolation vom Host-Netz
    hostBridge     = "br-media";    # Eigene Bridge (getrennt von br-vpn)

    # Kein VPN-Zwang. Dienste kommunizieren über normale Bridge nach außen.
    # Caddy auf dem Host terminiert TLS und reicht via UDS rein.

    bindMounts = {
      "/run/caddy" = {
        hostPath   = "/run/caddy-exposed";
        isReadOnly = false;
      };
      "/var/lib/jellyfin" = {
        hostPath   = "/persist/jellyfin";
        isReadOnly = false;
      };
      "/var/lib/audiobookshelf" = {
        hostPath   = "/persist/audiobookshelf";
        isReadOnly = false;
      };
      "/var/lib/radarr" = {
        hostPath   = "/persist/radarr";
        isReadOnly = false;
      };
      "/var/lib/sonarr" = {
        hostPath   = "/persist/sonarr";
        isReadOnly = false;
      };
      # Medienbibliothek (Read-Write für Radarr/Sonarr Umbenennung)
      "/mnt/media" = {
        hostPath   = "/mnt/media";
        isReadOnly = false;
      };
      # DISK_CACHE für Jellyfin Transcoding-Temp
      "/mnt/cache/transcoding" = {
        hostPath   = "/mnt/cache/transcoding";
        isReadOnly = false;
      };
    };

    config = { pkgs, config, ... }: {
      # Intel QuickSync Hardware-Transcoding
      hardware.opengl.enable        = true;
      hardware.opengl.extraPackages = [ pkgs.intel-media-driver ];

      services.jellyfin = {
        enable   = true;
        # Socket-Konfiguration: Network → Bind to local network address
        # /run/caddy/jellyfin.sock (via Jellyfin-Konfigurationsdatei)
      };

      services.audiobookshelf = {
        enable = true;
        port   = 0;  # Wird via UDS exponiert, kein TCP-Port
      };

      services.radarr = {
        enable = true;
        # Radarr sieht Sonarr direkt über Container-internes Netz (KISS)
      };

      services.sonarr = {
        enable = true;
        # Sonarr sieht Radarr direkt (gleicher Container, keine UDS-Pflicht intern)
      };

      # Hardening: nftables – kein ausgehender Traffic ohne explizite Regel
      networking.nftables.ruleset = ''
        table inet media-hardening {
          chain output {
            type filter hook output priority 0; policy accept;
            # Loopback immer erlaubt (interne Service-Kommunikation)
            oifname "lo" accept
            # Container-internes Netz über br-media erlaubt
            oifname "br-media" accept
            # UDS-Kommunikation ist kein Netzwerk-Traffic (Filesystem)
            # Kein explizites Drop – exposed Dienste dürfen ins Internet
          }
        }
      '';
    };
  };

  # Host-Bridge für VAULT-EXPOSED
  networking.bridges."br-media".interfaces = [];
  networking.interfaces."br-media".ipv4.addresses = [{
    address      = "10.100.2.1";
    prefixLength = 24;
  }];

  # Socket-Verzeichnisse und /dev/dri pass-through für QuickSync
  systemd.tmpfiles.rules = [
    "d /run/caddy-exposed 0750 caddy caddy -"
    "d /mnt/cache/transcoding 0755 jellyfin media -"
  ];
}
```

---

## VI. ADR-040: DAS GESETZ DES ASSOZIATIVEN MININGS

Kein technischer Begriff ist eine Insel. Jeder Begriff (Seed) MUSS eine rekursive
Suche nach seinen technischen Abhängigkeiten (Satellites) auslösen.

Das Versäumnis, das technische Ökosystem eines Begriffs zu kartieren, ist ein
Verstoß gegen diese Verfassung.

### Mining-Kaskaden (Vollständiger Katalog)

#### Seed: `Storage` / `Festplatte` / `Disk`
```
Satellites (MANDATORY):
  → Disk-Label-Schema (DISK_SYSTEM, DISK_CACHE, DISK_STORAGE_*)
  → Auto-Bootstrap: Geschwindigkeitsmessung → Tier-Zuweisung (§IV.A)
  → Filesystem-Typ pro Tier (ZFS auf A / ext4 auf B,C)
  → MergerFS-Policy (category.create=epmfs PFLICHT)
  → MergerFS-Flags (func.getattr=newest, ignore_pp=true, allow_other=true)
  → Mount-Reihenfolge (ZFS vor MergerFS, systemd.mounts-Abhängigkeit)
  → Atomic-Move-Kompatibilität (Staging MUSS auf DISK_CACHE liegen)
  → FUSE-Permissions (allow_other, use_ino=true)
  → Spindown-Logik (hdparm/udev für SATA HDDs)
  → ZFS-ARC-Limit (boot.kernelParams zfs.zfs_arc_max)
  → Scrub-Schedule (services.zfs.autoScrub)
  → /persist/-Layout (Welche Dienste, welche Pfade?)
  → Schwellwert-Migration B→C (§IV.C)
  → No-RAID-Mandat (§IV.F)
  → Off-Site-Backup (Restic, §IV.F)
```

#### Seed: `VPN` / `WireGuard` / `Privado`
```
Satellites (MANDATORY):
  → Kill-Switch-Mechanismus (VAULT-VPN mit privateNetwork=true, §V.A)
  → Interface-Pass-through (nur wg-privado im Container sichtbar)
  → Leak-Protection (ohne aktives wg-Interface: nftables DROP policy)
  → nftables-Kill-Switch-Regeln (output chain: drop; lo + wg-privado: accept)
  → Container-Bridge-Isolation (br-vpn getrennt von br-media)
  → DNS-Leak-Prävention (systemd-resolved nur über VPN-Nameserver)
  → WireGuard-Persistent-Keepalive (25 Sekunden)
  → Secrets-Management (privateKey via sops, NIEMALS im Klartext)
```

#### Seed: `Caddy` / `Reverse-Proxy` / `Ingress`
```
Satellites (MANDATORY):
  → UDS-Pfad-Schema: /run/caddy-vpn/<service>.sock und /run/caddy-exposed/<service>.sock
  → Unix Domain Socket (UDS) statt TCP für ALLE Backend-Kommunikation (§VII.B)
  → TLS-Terminierung (ACME via Let's Encrypt oder Cloudflare-DNS-Challenge)
  → HSTS-Header (max-age=31536000; includeSubDomains)
  → CSP-Header (Content-Security-Policy)
  → systemd-Hardening: CapabilityBoundingSet=~, PrivateDevices=true,
    PrivateUsers=true, NoNewPrivileges=true, ProtectSystem=strict
  → Jellyfin: KEIN Cloudflare-Tunnel (ToS-Verletzung). Direkter Caddy-Ingress.
  → Port-Kollisions-Guard (90-policy/port-registry.nix)
  → Socket-Verzeichnis-Permissions (/run/caddy-vpn, /run/caddy-exposed)
```

#### Seed: `Container` / `nspawn` / `Vault`
```
Satellites (MANDATORY):
  → Welches Vault? VPN-Vault (§V.A) oder Exposed-Vault (§V.B)?
  → privateNetwork=true (IMMER – keine Ausnahme)
  → hostBridge (hardware-agnostisch: br-vpn oder br-media)
  → bindMounts für /persist/<service> (ZFS-Dataset)
  → bindMounts für /run/caddy (UDS-Socket-Verzeichnis)
  → Kein physischer Bus-Bezug außer VPN-Interface und /dev/dri (QuickSync)
  → Ephemeral vs. Persistent (ephemeral=false für Media-Vaults: Daten müssen bleiben)
  → GID 169 = media (Jellyfin, Sonarr, Radarr, SABnzbd, Prowlarr, ABS)
```

#### Seed: `MergerFS` / `JBOD` / `Media-Pool`
```
Satellites (MANDATORY):
  → category.create=epmfs (Atomic-Move-Kompatibilität – ZWINGEND)
  → func.getattr=newest (Metadaten-Konsistenz bei verteilten Dateien)
  → ignore_pp=true (Path-Preservation deaktivieren)
  → allow_other=true (Zugriff für Jellyfin/Sonarr/Radarr als non-root)
  → use_ino=true (konsistente Inode-Nummern)
  → dropcacheonclose=true (Cache-Korruption verhindern)
  → Staging-Pfad MUSS auf DISK_CACHE liegen (§IV.E)
  → Atomic-Move-Protokoll (§IV.E)
  → GID 169 media group (alle beteiligten Services als Members)
  → Spindown-Koexistenz (FUSE-Idle + hdparm -S für HDDs)
  → No-RAID-Mandat (§IV.F)
```

#### Seed: `Pocket-ID` / `SSO` / `OIDC`
```
Satellites (MANDATORY):
  → UDS-Kommunikation zu Caddy (/run/caddy/pocket-id.sock)
  → PASSWORD_AUTH_ENABLED=false (Passkey-Only – Akinator-Entscheid)
  → PostgreSQL-Backend (services.postgresql, NICHT SQLite für Produktion)
  → OIDC-Client-Registrierung pro Dienst (Vaultwarden, n8n, etc.)
  → Session-Secret via sops-nix (NIEMALS im Klartext in .nix)
  → Flake-Input: inputs.sops-nix.nixosModules.sops (KEIN NIX_PATH)
  → Backup: /persist/pocket-id/ → Restic → Cloud
```

#### Seed: `ZFS` / `DISK_SYSTEM`
```
Satellites (MANDATORY):
  → Pool: rpool (Konvention)
  → Dataset-Layout: rpool/local/nix, rpool/local/root, rpool/safe/home, rpool/safe/persist
  → compression=lz4 (performance-optimal)
  → atime=off (keine Access-Time-Updates auf rpool/local/nix)
  → xattr=sa (schnelle Extended-Attributes für sops-Secrets)
  → ARC-Max: boot.kernelParams ["zfs.zfs_arc_max=<bytes>"] (RAM/4)
  → Scrub: services.zfs.autoScrub.enable = true (weekly)
  → TRIM: services.zfs.trim.enable = true (für NVMe/SSD)
  → Sanoid: automatische Snapshots (services.sanoid)
  → hostId: networking.hostId (eindeutig pro Host, aus sops)
  → /persist/-Dataset ist ZFS (rpool/safe/persist), KEIN tmpfs
```

#### Seed: `SSH` / `Fernzugang`
```
Satellites (MANDATORY):
  → PermitRootLogin = "no"
  → PasswordAuthentication = false
  → PermitEmptyPasswords = false
  → MaxAuthTries = 3
  → AllowTcpForwarding = false
  → X11Forwarding = false
  → KexAlgorithms = ["sntrup761x25519-sha512@openssh.com"] (quantum-safe)
  → HostKeyAlgorithms = ["ssh-ed25519"]
  → Macs = ["hmac-sha2-512-etm@openssh.com"]
  → Authorized-Keys: via sops-nix (NIEMALS Klartext im Repo)
```

#### Seed: `Secrets` / `sops-nix` / `SOPS`
```
Satellites (MANDATORY):
  → Flake-Import: inputs.sops-nix.nixosModules.sops (KEIN <sops-nix/...>)
  → .sops.yaml: age-Key im Repo, Host-SSH-Key als Entschlüsseler
  → Secrets-Pfade: /run/secrets/<name> (ephemer, RAM-backed)
  → NIEMALS Klartext-Secrets in .nix oder flake.nix
  → age-Key-Backup: /persist/secrets/age-key.txt (ZFS-gesichert)
  → Key-Rotation-Protokoll: sops updatekeys bei Hardware-Wechsel
```

---

## VII. UNVERÄNDERLICHE PRINZIPIEN

### A. Software-Selektion (Prioritäts-Kaskade)

```
1. Natives NixOS-Modul (services.X.enable)     ← Absolute Priorität
2. Nixpkgs-Paket + eigener systemd-Unit
3. Community-Flake (battle-tested, >6 Monate stabil)
4. VERBOTEN: Docker / Podman / OCI (keine Ausnahmen)
```

### B. IPC-Gesetz: Unix Domain Sockets (UDS) – Das Lateral-Movement-Gesetz

**Herkunft:** Architecture Review (geminiverbesserung.txt, 2026-03-03)
> "Der Caddy-Reverse-Proxy kommuniziert über einen lokalen TCP-Port mit dem SSO-Dienst.
> Dies eröffnet Angriffsvektoren für Lateral Movement innerhalb des Host-Netzwerks.
> Eine Kommunikation über Unix-Domain-Sockets ist hier zwingend erforderlich."

**Das Gesetz:** Jede Kommunikation zwischen Caddy und einem Backend-Dienst MUSS über
Unix Domain Sockets (UDS) erfolgen. TCP auf `localhost` ist VERBOTEN.
Dies gilt für: Pocket-ID, VAULT-VPN-Dienste, VAULT-EXPOSED-Dienste.

```nix
# 20-server/caddy.nix – UDS-Konfiguration (vollständig)
# [META] ID: NIXH-20-SRV-001 | ADR: ADR-008 | Version: 1.1 | Stage: 2
{ config, pkgs, ... }:
{
  services.caddy = {
    enable = true;
    virtualHosts = {

      # Pocket-ID SSO via UDS (KORREKT – kein TCP)
      "id.${config.networking.domain}" = {
        extraConfig = ''
          reverse_proxy unix//run/caddy/pocket-id.sock {
            header_up Host {host}
          }
        '';
      };

      # Jellyfin via UDS in VAULT-EXPOSED
      "media.${config.networking.domain}" = {
        extraConfig = ''
          reverse_proxy unix//run/caddy-exposed/jellyfin.sock {
            header_up Host {host}
            header_up X-Real-IP {remote_host}
          }
        '';
      };

      # Prowlarr via UDS in VAULT-VPN
      "indexer.${config.networking.domain}" = {
        extraConfig = ''
          reverse_proxy unix//run/caddy-vpn/prowlarr.sock
        '';
      };

      # Vaultwarden via UDS (Host-Dienst, kein Container)
      "vault.${config.networking.domain}" = {
        extraConfig = ''
          reverse_proxy unix//run/caddy/vaultwarden.sock
        '';
      };
    };
  };

  # systemd-Hardening für Caddy (CIS-Compliant)
  systemd.services.caddy = {
    serviceConfig = {
      CapabilityBoundingSet    = "~";
      PrivateDevices           = true;
      PrivateUsers             = true;
      NoNewPrivileges          = true;
      ProtectSystem            = "strict";
      ProtectHome              = true;
      ProtectKernelTunables    = true;
      ProtectKernelModules     = true;
      ProtectControlGroups     = true;
      RestrictAddressFamilies  = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      RestrictNamespaces       = true;
      LockPersonality          = true;
      MemoryDenyWriteExecute   = true;
    };
  };

  # Socket-Verzeichnisse mit korrekten Rechten
  systemd.tmpfiles.rules = [
    "d /run/caddy         0750 caddy caddy -"
    "d /run/caddy-vpn     0750 caddy caddy -"
    "d /run/caddy-exposed 0750 caddy caddy -"
  ];
}
```

### C. No-Legacy-Mandat

| Funktion    | Legacy (VERBOTEN)          | Moderne Alternative (PFLICHT) |
|-------------|----------------------------|-------------------------------|
| Proxy       | Traefik, Nginx             | Caddy (Go)                    |
| Firewall    | iptables                   | nftables                      |
| Boot        | GRUB                       | systemd-boot + UEFI           |
| Pakete      | Channels                   | Flakes only                   |
| GPU         | generische Treiber         | iHD (Intel QSV, QuickSync)    |
| IPC         | TCP auf localhost          | Unix Domain Sockets (UDS)     |
| Cache/KV    | Redis                      | Valkey                        |
| Metadaten   | `options.my.meta.*`        | Externe YAML/JSON-DB          |
| Container   | Docker, Podman, OCI        | systemd-nspawn (nativ)        |
| Flake-Pfad  | `<sops-nix/modules/sops>`  | `inputs.sops-nix.nixosModules.sops` |

### D. SSH-Hardening (CIS-Compliant, vollständig)

```nix
# [META] ID: NIXH-00-COR-002 | ADR: ADR-001 | Version: 1.0 | Stage: 2
# 00-core/ssh.nix
{ config, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin        = "no";
      PasswordAuthentication = false;
      PermitEmptyPasswords   = false;
      MaxAuthTries           = 3;
      AllowTcpForwarding     = false;
      X11Forwarding          = false;
      PrintMotd              = false;
      KexAlgorithms          = [ "sntrup761x25519-sha512@openssh.com" ];
      HostKeyAlgorithms      = [ "ssh-ed25519" ];
      Macs                   = [ "hmac-sha2-512-etm@openssh.com" ];
    };
  };

  users.users.mo.openssh.authorizedKeys.keyFiles = [
    config.sops.secrets."ssh-authorized-keys".path
  ];
}
```

### E. Flake-Purity-Gesetz

Flake-Konfigurationen sind per Definition pure. Jeglicher `<...>`-Pfad-Import ist ein
Build-Fehler in Flake-Kontexten und VERBOTEN.

```nix
# KORREKT (Flake-pure):
imports = [ inputs.sops-nix.nixosModules.sops ];

# VERBOTEN (Flake-Purity-Verletzung, Build-Fehler):
imports = [ <sops-nix/modules/sops> ];
```

### F. Modularitäts-Mandat (Dendritic-Pattern)

```
Werkzeuge:  flake-parts + import-tree (stabil, community-validated)
Regel:      Eine Datei = Ein Feature. NixOS + Home-Manager eines Dienstes → eine Datei.
Verboten:   specialArgs-Tunnel für Metadaten
Verboten:   options.my.meta.* (bläht Evaluierungsbaum, Flaschenhals bei >100 Services)
```

---

## VIII. PFAD-REINHEIT: DAS ABSOLUTE SCHREIB-MANDAT

| Pfad | Regel |
|------|-------|
| `/root/` | **ABSOLUTE VERBOTSZONE.** Kein Schreiben, keine Temp-Dateien, keine ADRs, keine Skripte |
| `/tmp/` | Nur Read-Only für `git clone`. Keine permanenten Artefakte. |
| `/home/Werkstatt/` | Ausschließlich `.nix`-Dateien. Keine Skripte, kein Markdown. |
| `/home/Knowledge-Pipeline/` | Alle Wissens-Artefakte, Chatlogs, ADRs, Dokumente. |

**Erlaubt in `/root/`:** Temporäre Binary-Ausführung (MCP-Server-Binaries, Go-Tools während Laufzeit).
**Verboten in `/root/`:** Dokumente, ADRs, Skript-Quellen, GEMINI.md, irgendwelche .md/.nix-Dateien.

**Datei-Schreib-Methode:** Python-Direkt-Write oder `tee`.
- VERBOTEN: `cat << EOF` (Syntaxfehler bei Sonderzeichen in langen Texten)
- VERBOTEN: `printf` mit Sonderzeichen
- PFLICHT: Nach jeder Datei-Operation → `ls -la /root/` (Reinheits-Nachweis im Log)

---

## IX. RAG-FIRST OPERATIONS & AGENTEN-LOGIK

### A. Query-Zwang (vor jeder Code-Generierung)

```
1. RAG-Vektorstore konsultieren   (.vectorstore/ via gemini_cli_query_tool)
2. Almanach cross-referenzieren   (/home/Knowledge-Pipeline/Almanach/)
3. Erzmine auf Nuggets prüfen     (/home/Knowledge-Pipeline/Erzmine/)
4. ISO-Compliance-Check:          "Funktioniert das auch mit anderen Labels auf anderer Hardware?"
5. Erst dann: Code schreiben
```

### B. Beweispflicht

```bash
# Nach jeder Datei-Operation:
ls -la /home/Werkstatt/
head -n 3 /home/Werkstatt/<neue-datei>.nix  # Zeigt [META]-Header

# Nach Archivierung:
ls -la /home/Knowledge-Pipeline/oldGeminis/

# Reinheits-Nachweis (PFLICHT):
ls -la /root/    # Muss sauber sein
```

### C. Anti-Halluzinations-Gesetz

```
PFLICHT:    Bei Nix-Optionen/API-Fragen → context7 ZUERST befragen
VERBOTEN:   "..." oder "wie oben" als Platzhalter → Systemverstoß
VERBOTEN:   Simulieren von Tool-Outputs
VERBOTEN:   sed -i auf Systemdateien
VERBOTEN:   pkill auf unbekannte Prozesse
VERBOTEN:   SSH/systemd-Manipulation ohne expliziten Auftrag
VERBOTEN:   options.my.meta.* (Evaluierungsbaum-Bloat)
PFLICHT:    Alles deklarativ über Nix – niemals manuell
```

### D. Sieben Qualitäts-Tore (jede .nix-Datei)

| Gate | Prüfung | Tool |
|------|---------|------|
| 1 | Community-Goldstandard: Abgleich mit nixpkgs/modules | context7 |
| 2 | API-Accuracy: Optionen existieren wirklich | context7 |
| 3 | SSoT-Compliance: Port-Registry + sops-Secrets | 90-policy |
| 4 | SRE-Hardening: systemd-analyze security < 4.0 | systemd |
| 5 | Dendritische Integrität: Eine Datei = Ein Service | Review |
| 6 | Hygiene: Kein options.my.meta.*, kein toter Code | Review |
| 7 | Traceability: [META]-Header vorhanden und korrekt | Header-Audit-Skript |

---

## X. WISSENSBASIS-STANDARD (DREI-LAYER-PFLICHT)

Jedes Dokument im Almanach MUSS drei Schichten enthalten:

```
Layer 1 – USER (KISS):     Was ist das? Wofür brauche ich es? (≤ 5 Sätze, laienhaft)
Layer 2 – TECHNICAL:       Vollständige Spezifikation, Nix-Code, Flags, Pfade, Parameter
Layer 3 – REASONING (ADR): Warum diese Entscheidung? Was wurde verworfen? Mit Quelle.
```

**Wissens-Wachstum (absolutes Löschverbot):**
```
[CONTEXT7-ENRICHMENT]    – Aus Context7 verifiziert
[SEARCH-ENRICHMENT]      – Aus Web-Recherche
[ARCHITECT-NOTE]         – Interne logische Herleitung
[PATTERN-MINING: <repo>] – Aus GitHub-Pattern-Mining
[DEPRECATED]             – Überholt. Bleibt im Reasoning Layer. Nie löschen.
```

---

## XI. GITHUB-PATTERN-MINING-PROTOKOLL

```
Bei Account-Links (nicht einzelne Repos):
  → Liste nur Repos mit *.nix-Dateien
  → Filter: Tags nixos, homelab, nix-config, self-hosted
  → Nur Repos mit Aktivität in 2024 oder 2025
  → Zeige gefilterte Liste → Mo wählt aus

Erlaubt:   README.md, flake.nix, *.nix aus modules/ oder hosts/
Verboten:  src/ (Quellcode), lock-files, .github/ (CI)
Ziel:      /home/Knowledge-Pipeline/raw/sources/<repo-name>/
Output:    /home/Knowledge-Pipeline/raw/sources/<repo-name>-patterns.md
Veredelung: Nach /Almanach/ (Drei-Layer-Standard) auf explizite Anweisung
Markierung: [PATTERN-MINING: <repo>]
```

---

## XII. MCP-SERVER & TOOLING

### Start-Validierung (bei jeder Session)

```
KRITISCH (Ausfall sofort melden, kein stilles Scheitern):
  context7        → NixOS-API-Accuracy (Pflicht vor jedem options.*-Zugriff)
  nixos           → Nix-Optionen Validierung

WICHTIG:
  open-websearch  → Live Best-Practices, aktuelle nixpkgs-Änderungen
  github          → Referenz-Repository Scans

VERBOTEN: Tool-Outputs simulieren. Bei Ausfall → SOFORT melden, Aktion pausieren.
```

---

## XIII. GIT-SYNC-PROTOKOLL

```
Werkstatt-Repo: /home/Werkstatt/                  → git commit nach jeder .nix-Änderung
Knowledge-Repo: /home/Knowledge-Pipeline/docs/    → Branch main

Commit-Prefix-Konvention:
  adr:       Architecture Decision Records
  services:  Dienst-Konfigurationen
  learnings: Erkenntnisse aus Debugging-Sessions
  guides:    Schritt-für-Schritt-Anleitungen
  patterns:  GitHub-Pattern-Mining-Ergebnisse
  storage:   Storage/Disk-Konfigurationen
  security:  Sicherheits-Änderungen
  meta:      Metadaten-Header-Updates

Tokens: Nur via Umgebungsvariablen – NIEMALS im Klartext in .nix oder .md
```

---

## XIV. HARDWARE-REFERENZ (INFORMATIV – NICHT NORMATIV)

Die Hardware-Referenz ist ein Beispiel-Mapping. Sie ist KEIN Bestandteil der Architektur.
Alle Module sind label-basiert und hardware-agnostisch.

```
[DEPRECATED: Hardware-spezifisch, nur zur Orientierung]
Gerät:  Fujitsu Q958 (Formfaktor: Mini-PC)
CPU:    Intel Core i3-9100 (4C/4T, 3.6 GHz base)
RAM:    16 GB DDR4
GPU:    Intel UHD 630 (QuickSync = iHD, Hardware-Transcoding via /dev/dri)
IP:     192.168.2.73 (lokales Netz – nicht normativ)

Tier-Mapping-Beispiel (Q958-spezifisch, via Auto-Bootstrap ermittelt):
  DISK_SYSTEM    ← Samsung NVMe (M.2 Main-Slot)    [> 1 GB/s → Tier A]
  DISK_CACHE     ← Apacer SSD (M.2 WLAN-Slot)     [~ 500 MB/s → Tier B]
  DISK_STORAGE_* ← SATA-HDDs (SATA-Ports 0-N)     [< 200 MB/s → Tier C]
```

---

## XV. ARCHIV-MANDAT & EVOLUTION-LOG

### Archiv-Direktive (einmalig auf Server ausführen)

```bash
#!/usr/bin/env bash
# Archiviert alle Vorgänger-Versionen in das historische Museum
set -euo pipefail

OLD_GEMINI_DIR="/home/Knowledge-Pipeline/oldGeminis"
ARCHIVE_DIR="/home/Knowledge-Pipeline/Erzmine/02-ARCHIVE/versions"
mkdir -p "$OLD_GEMINI_DIR"

echo "📦 Archiviere historische Verfassungen..."

# Aus Erzmine/versions kopieren
for version in v7.0 v10.0 v11.0 v12.0; do
  src="$ARCHIVE_DIR/GEMINI_${version}.md"
  [ -f "$src" ] && cp "$src" "$OLD_GEMINI_DIR/" && echo "  ✅ ${version} gesichert" || echo "  ⚠️  ${version} nicht gefunden"
done

# Aktuelle Werkstatt-Kopie als v13.0 sichern (vor Überschreiben)
[ -f "/home/Werkstatt/GEMINI.md" ] && cp "/home/Werkstatt/GEMINI.md" "$OLD_GEMINI_DIR/GEMINI_v13.0_legacy.md" && echo "  ✅ v13.0 (aktuell) gesichert"

echo ""
echo "📋 Museum-Inhalt:"
ls -lh "$OLD_GEMINI_DIR"

echo ""
echo "🧹 Reinheits-Nachweis:"
ls -la /root/

echo "✅ Archivierung abgeschlossen. v14.0 ist jetzt aktiv."
```

### Reconciliation Log: Was v14.0 zu v12.0 hinzufügt

| # | Änderung | Quelle | Vorgänger |
|---|----------|--------|-----------|
| 1 | Der Veredelungs-Zyklus (Stage 1/2/3 + Goldschmelz-Checkliste) | Gemini Akinator-Session | — (neu) |
| 2 | Akinator-Protokoll als Betriebsgesetz (Lastenheft-Zwang) | Gemini Batch 1-3 | — (neu) |
| 3 | Auto-Bootstrap: Geschwindigkeitsbasierte Tier-Zuweisung | Akinator-Session | v11.0 (statisch) |
| 4 | Single-Drive-Szenarien (NVMe/SSD allein → Tier A+B merge) | Akinator-Entscheid | — (fehlte) |
| 5 | Schwellwert-Gesetz B→C (95% forced, 80-85% opportunistisch) | Akinator-Entscheid Batch 3 | — (fehlte) |
| 6 | Zwei-Vault-Modell (VPN-Vault + Exposed-Vault) | Akinator-Entscheid Batch 3 | v12.0 (ein Vault) |
| 7 | VAULT-VPN vollständig (Prowlarr+SABnzbd, nftables Kill-Switch) | Akinator + v12.0 | v12.0 (fragment) |
| 8 | VAULT-EXPOSED vollständig (Jellyfin+ABS+Radarr+Sonarr) | Akinator + v12.0 | — (neu) |
| 9 | KISS-Prinzip für internes Servarr-Netz (kein UDS intern) | Akinator-Entscheid | — (fehlte) |
| 10| Metadaten-Header [META] mit Versions-Gesetz (+0.1) | Akinator-Entscheid | — (fehlte) |
| 11| Header-Audit-Skript (bash, non-blocking) | Architektur-Synthese | — (neu) |
| 12| Tier-Migration systemd-Timer (Nacht, Prio=idle) | Akinator-Entscheid | — (fehlte) |
| 13| Spatial Map mit vollständiger Werkstatt-Topographie | v13.0 Entwurf | v12.0 (implizit) |
| 14| oldGeminis/ als Audit-Museum definiert | v13.0 Entwurf | — (neu) |
| 15| Alle Erzmine-Nuggets aus v12.0 erhalten (UDS, options.my.meta.*, SSH) | v12.0 | Vollständig erhalten |

---

*GEMINI.md v14.0 – Generiert: März 2026*
*Architektur: Mo (Entscheidungsträger) + Claude (Architecture Master) + Gemini CLI (On-Server Execution)*
*Nächste Review: Nach erstem vollständigem Zwei-Vault-Betrieb*
*Nächste geplante Version: v15.0 – Nach Completion Traceability-Matrix für 160 Werkstatt-Dateien*
