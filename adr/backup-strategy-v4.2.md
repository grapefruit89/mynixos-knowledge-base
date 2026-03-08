# 🏗️ [ADR]: 3-2-1 Backup-Strategie mit Restic & Rclone (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir sorgen dafür, dass deine Daten nie verloren gehen, selbst wenn dein Haus abbrennt oder dein Server gehackt wird. Wir machen drei Kopien an verschiedenen Orten.
- **Problem:** Festplatten gehen kaputt, und Hacker können Dateien verschlüsseln.
- **Lösung:** Wir nutzen "Restic" zum Verschlüsseln der Backups und "Rclone", um sie zu verschiedenen Cloud-Anbietern (wie Koofr oder Mega) zu schicken.
- **Vorteil:** Selbst wenn ein Anbieter pleite geht oder dein Server explodiert – deine Fotos und Dokumente sind sicher und nur für dich lesbar.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation der Backup-Infrastruktur.

### 📜 2.1 Die 3-2-1 Regel
1.  **3 Kopien:** 1x Lokal (Live), 1x Lokal (Backup-Disk), 1x Cloud (Remote).
2.  **2 Medien:** ZFS Mirror (Bitrot-Schutz) und Cloud-Storage (verschlüsselte Chunks).
3.  **1 Extern:** Offsite-Backup in der Cloud.

### 🛠️ 2.2 Tool-Stack & Konfiguration
- **Restic:** Splittet Daten in Chunks, dedupliziert und verschlüsselt lokal (`restic init --repository-version 2`).
- **Rclone:** Dient als Transport-Layer für WebDAV (Koofr), S3 oder B2.
- **Append-only Repositories:** Schutz gegen Ransomware. Das Backup-Passwort darf nur schreiben, das Lösch-Passwort liegt offline.
- **ZFS Snapshots:** Restic sichert von Snapshots (`sanoid`), um Inkonsistenzen bei laufenden Datenbanken zu vermeiden.

### 📂 2.3 Speicher-Allokation
- **Koofr (1TB):** Haupt-Repository für Medien und große Archive.
- **Mega/Filen (30-50GB):** Zweitkopie für kritische Daten (Fotos, sops-keys).

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Deduplizierung:** Restic spart massiv Platz in der Cloud, da nur geänderte Datenblöcke hochgeladen werden.
- **Verschlüsselung:** Durch die lokale Verschlüsselung sieht der Cloud-Anbieter niemals die Dateiinhalte – Bitwarden-Prinzip für das gesamte Dateisystem.
- **Automatisierung:** Systemd-Timer stellen sicher, dass Backups nachts laufen und regelmäßig auf Integrität geprüft werden (`restic check`).

> [SOURCE-ENRICHMENT]: Extracted from `Claude-02 Homeserver mit Cloudflare sicher einrichten.md` (6.3.2026).
