# [ADR-040]: Storage Architecture - No Redundancy / Anti-Waste
# ID: [ADR-040] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir lehnen RAID, SnapRAID und Parität ab. Es ist Ressourcenverschwendung. Wir nutzen 100% des gekauften Speicherplatzes. Sicherheit kommt durch Backups, nicht durch Live-Redundanz.

## 2. Technical Layer
- **Pooling:** Nutzung von `mergerfs` ausschließlich zum Zusammenfassen von Pfaden.
- **Keine Parität:** Verzicht auf dedizierte Paritäts-Platten.
- **Kein RAID:** Jede Festplatte bleibt als eigenständiges Dateisystem (XFS/BTRFS) erhalten.
- **Wiederherstellung:** Im Falle eines Defekts wird die betroffene Platte aus dem Backup (Restic/Rclone) wiederhergestellt.

## 3. Reasoning Layer
- **Effizienz:** 100% Nutzkapazität.
- **Einfachheit:** Keine komplexen RAID-Arrays, die bei Fehlern den ganzen Pool gefährden.
- **Hardware-Schonung:** Platten müssen nicht synchron rotieren.

---
> [SOURCE]: Benutzer-Mandat gegen Ressourcenverschwendung (10.03.2026)
