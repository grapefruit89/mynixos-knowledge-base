# 💎 Storage-Security-Meta (Universal Portability Standard)
# ID: [SSOT-STORAGE-001] | Stand: 10.03.2026 | Status: DEFINITIVE | v2.0

Dieses Dokument definiert den universellen ISO-Standard für Storage und Sicherheit. Es entkoppelt die logische Struktur von physischen Hardware-Slots. 

---

## 🏛️ A. SYSTEM PHILOSOPHY: Souveränität & Abstraktion

1.  **Souveränität (ADR-032):** Wir lehnen externe Abhängigkeiten (GitHub) während des Builds ab. Alle Quellen (nixpkgs) werden lokal in Forgejo gespiegelt.
2.  **Rollen-Basierte Tiers:** Wir definieren Speicher nach Funktion, nicht nach Bus-Adresse. Die Zuweisung erfolgt über **Disk-Labels**.
3.  **Daten-Autonomie (No-RAID):** Jede Festplatte arbeitet als unabhängige Einheit (JBOD). RAID/SnapRAID/Stripping sind verboten.
4.  **Der "Nothammer":** Container-Isolation ist die Ausnahme für Hochrisiko-Dienste.

---

## 💾 B. STORAGE-META (ROLE-BASED TIERING)

| Tier | Funktion | Label-Pflicht | Dateisystem |
| :--- | :--- | :--- | :--- |
| **Tier A** | System, State, /persist | `DISK_SYSTEM` | **ZFS** (Single) |
| **Tier B** | Cache, Transcoding | `DISK_CACHE` | **ext4** |
| **Tier C** | Mass Archive (JBOD) | `DISK_STORAGE_*` | **ext4** (JBOD) |

### 🔧 Management
- **Identifikation:** Ausschließlich via `/dev/disk/by-label/` (ISO-Standard).
- **[DEPRECATED]:** Die Bindung an Fujitsu Q958 Slots (Main M.2, WLAN Slot) ist als Referenz-Hardware erhalten, aber nicht mehr zwingend.
- **Pooling:** MergerFS verbindet alle Platten mit dem Präfix `DISK_STORAGE_` zu `/mnt/media`.

---

## 🔄 C. MERGERFS & ATOMIC MOVE SPECIFICATION

Um **Atomic Moves** (zero-copy) zu garantieren, muss die physische Lokation der Daten auf der gleichen Platte erzwungen werden:

1.  **Staging:** Downloads landen im `.staging` Ordner des Ziel-Labels (`DISK_STORAGE_X`).
2.  **MergerFS Flags (Mandat):**
    - `category.create=epmfs` (Existing Path Most Free Space)
    - `func.getattr=newest`
    - `ignore_pp=true`

---

## 🛡️ D. SECURITY & VPN AUDIT (UNIVERSAL VAULT)

### 1. Hardware-Agnostische Isolation
- **Technik:** NixOS Container mit `privateNetwork = true`.
- **Netzwerk:** Nutzung von dynamischen Bridge-Interfaces (z.B. `br0`), die NixOS beim Booten unabhängig von der physischen NIC (eth0/wlan0) erstellt.
- **Kill-Switch:** Physisches Durchreichen des VPN-Interfaces (wg-privado) bleibt der Goldstandard für Leak-Protection.

---

## 🗺️ E. KNOWLEDGE MAPPING (RECONCILIATION LOG)
- **v1.0:** Hardware-Diktatur (Slots) -> **[SUPERSEDED]**
- **v2.0:** Rollen-Abstraktion (Labels) -> **AKTIV**

---
> [!IMPORTANT]
> Dieses Dokument ist die einzige Quelle der Wahrheit für universell portable mynixos Installationen.
