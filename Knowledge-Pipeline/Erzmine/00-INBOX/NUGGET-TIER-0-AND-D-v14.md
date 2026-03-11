# [NUGGET-TIER-0-AND-D] High-Speed RAM & Transient USB (v14.0)
# Status: Stage 1 (Raw-Research) | Version: 1.0
# [META] ID: NIXH-KNOW-STORAGE-002 | REQ_REFS: [ADR-012, ADR-033]

## 1. USER LAYER (KISS)
- **Tier 0 (RAM):** Das Betriebssystem läuft direkt im Arbeitsspeicher. Das macht den Server extrem schnell und schont die Festplatten.
- **Tier D (USB):** Externe Platten werden wie bei Unraid einfach angesteckt. Sie melden sich automatisch an, wenn man sie braucht, und melden sich ab, wenn sie 5 Minuten nicht benutzt wurden.
- **Landkarten-Prinzip:** Der Server merkt sich, welche Filme auf welchen Platten liegen, ohne dass die Platten dafür ständig mitlaufen müssen.

## 2. TECHNICAL LAYER (SPECIFICATION)

### Tier 0: Root-on-Tmpfs (RAM-Disk)
- **Implementation:** `fileSystems."/" = { device = "none"; fsType = "tmpfs"; options = [ "size=4G" "mode=755" ]; };`
- **Benefit:** Eliminiert Disk-I/O für Systemoperationen. Erfordert strikte Impermanence-Struktur (`/persist`).

### Tier D: systemd.automount (Transient USB)
- **Options:** `x-systemd.automount`, `x-systemd.idle-timeout=300`, `x-systemd.mount-timeout=10`.
- **Logic:** Mount erfolgt erst bei Zugriff auf `/mnt/transient/<label>`. Unmount nach 300s Inaktivität.
- **Bus-Guard:** Automount-Units werden dynamisch für Geräte generiert, deren `ID_BUS == "usb"`.

### Metadata-Map: MergerFS Caching
- **Flags:** `cache.files=true`, `dropcacheonclose=true`, `cache.statfs=true`.
- **Logic:** Verzeichnisstruktur wird im RAM (Tier 0) oder auf Tier B (SATA SSD) gepuffert. 
- **Spin-up Policy:** HDDs bleiben im Standby (Sleep), solange nur Metadaten (Dateilisten) gelesen werden.

## 3. REASONING LAYER (ADR)
- **Warum Automount?** Schützt vor Dateisystemfehlern beim plötzlichen Abziehen (Transient-Hardware) und spart Energie.
- **Warum Metadata Cache?** Das "Browsing-Delay" bei großen HDD-Arrays wird eliminiert. Die UX entspricht einer reinen SSD-Umgebung.
- **Warum Root-on-Tmpfs?** Maximale Sicherheit und Geschwindigkeit. Ein Reboot setzt das System in einen definierten Gold-Status zurück.
