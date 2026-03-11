# [NUGGET-MERGERFS-SUPREMACY] The Landlord of HDDs (v14.0)
# Status: Stage 1 (Research) | Version: 1.0
# [META] ID: NIXH-KNOW-STORAGE-003 | REQ_REFS: [ADR-012, ADR-040]

## 1. USER LAYER (KISS)
- **MergerFS:** Bündelt alle deine Festplatten zu einem riesigen virtuellen Ordner.
- **Intelligente Verteilung:** Filme werden immer dort gespeichert, wo am meisten Platz ist.
- **HDD-Schutz:** Die Platten schlafen, solange du nur guckst, was da ist. Erst beim Abspielen wacht die richtige Platte auf.
- **Sicherheits-Mount:** USB-Sticks werden so gemountet, dass Daten sofort geschrieben werden. Man kann sie fast immer abziehen, ohne Datenverlust zu riskieren.

## 2. TECHNICAL LAYER (SPECIFICATION)

### MergerFS Policy (Tier C)
- **Mount-Optionen:** `allow_other,use_ino,cache.files=partial,dropcacheonclose=true,category.create=mfs,moveonenospc=true,minfreespace=20G,fsname=mergerfs_pool`.
- **Metadata-Caching:** Durch `cache.files=partial` hält der Kernel die Verzeichnisstruktur im RAM. Ein `ls -R` weckt keine HDDs auf.

### Tier 0: Root-on-Tmpfs Hard-Limit
- **NixOS Config:**
  ```nix
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=1G" "mode=755" ];
  };
  ```
- **Constraint:** Verhindert RAM-Exhaustion durch Amok-laufende Logs oder temporäre Dateien im Root-Pfad.

### Tier D: USB-Automount (Sync-Safety)
- **Udev Rule:** `ACTION=="add", SUBSYSTEMS=="usb", ..., RUN+="/run/current-system/sw/bin/systemd-mount --options=sync,nosuid,nodev --automount=yes $devnode /mnt/transient/%E{ID_FS_LABEL_ENC}"`
- **Idle-Timeout:** `x-systemd.idle-timeout=300` sorgt für automatische Trennung nach 5 Min Inaktivität.

## 3. REASONING LAYER (ADR)
- **Warum sync für USB?** Homelab-User ziehen Sticks oft ohne "Eject". `sync` minimiert das Korruptionsrisiko auf Kosten der Schreibgeschwindigkeit.
- **Warum mfs (Most Free Space)?** Verhindert ungleichmäßige Abnutzung der Platten und sorgt für Puffer auf allen Medien.
- **Warum 1GB Limit?** Ein Schutzwall für das RAM-Management. Da `/nix` auf der NVMe liegt, reicht 1GB für `/etc` und `/var` (Symlinks) locker aus.
