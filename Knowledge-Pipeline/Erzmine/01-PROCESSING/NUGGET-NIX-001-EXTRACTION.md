# [RAW-GOLD]: Awesome-Nix Deep Dive 2026
# ID: [NUGGET-NIX-001] | Stand: 10.03.2026

## 1. Fundstelle: Impermanence
- **Konzept:** Root-FS auf tmpfs oder ZFS-Snapshot (blank).
- **Vorteil:** Keine Konfigurations-Drift möglich. Alles muss deklarativ sein.
- **Nix-Modul:** `nix-community/impermanence`.

## 2. Fundstelle: MicroVM.nix
- **Konzept:** Dienste in winzigen VMs statt Containern.
- **Vorteil:** Kernel-Isolation. Host bleibt unangreifbar.
- **Performance:** <500ms Startzeit, virtiofs share.

## 3. Fundstelle: Dendritic Framework (den)
- **Konzept:** Automatische Modul-Erkennung via `import-tree`.
- **Vorteil:** Verhindert Zirkelbezüge und vereinfacht Refactoring.

## 4. Fundstelle: Hardening Scores
- **Konzept:** Systemd Sandboxing konsequent durchziehen.
- **Tools:** `systemd-analyze security` als Maßstab.
