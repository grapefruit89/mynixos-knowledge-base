# Service: Master-Stick Plug-and-Sync Automation

## 1. User Layer (KISS)
Dieses Dokument beschreibt die "Geister-Hand" deines Servers. Du musst keinen Befehl tippen, um ein Backup zu machen. Es reicht, wenn du deinen Master-USB-Stick kurz einsteckst. Der Server erkennt den Stick an seiner Seriennummer, lädt die wichtigsten Daten hoch und gibt dir Bescheid, wenn er fertig ist. Danach ziehst du den Stick einfach wieder ab.

## 2. Technical Layer (Aviation-Grade)

### Udev-Trigger Logik
Das System lauscht auf die exakte Hardware-ID (`ID_SERIAL_SHORT`) des Sticks.
*   **Trigger-Regel:** `ACTION=="add", SUBSYSTEM=="block", ENV{ID_SERIAL_SHORT}=="XXXX", RUN+="..."`
*   **Service:** `nms-master-sync.service` (Type=oneshot).

### Ablauf des Sync-Events
1.  **Erkennung:** Stick wird eingesteckt -> udev startet systemd-Service.
2.  **Mount:** Die verschlüsselte Partition `NMS_IDENTITY` auf dem Stick wird kurzzeitig gemountet.
3.  **Sync:** `restic backup` sichert den Tier-A State in die Cloud (S3).
4.  **Handoff:** Aktuelle Keys/Mappings werden vom Server auf den Stick gesichert (Recovery-Sicherung).
5.  **Unmount:** Partition wird getrennt, Stick kann sicher entfernt werden.

### Monitoring via Dashboard
Der Status des letzten Handshakes wird in `/run/nixhome-cache/storage-status.json` geschrieben und auf dem Homepage-Dashboard visualisiert.

## 3. Reasoning Layer (History)

### [ARCHITECT-NOTE] Plug-and-Sync vs. Permanent Mount
Die Entscheidung für den Plug-and-Sync Ansatz schont die Hardware des USB-Sticks (kein permanenter Schreibzugriff) und erhöht die Sicherheit. Der Stick ist nur dann angreifbar, wenn er physisch steckt. Im Rest der Zeit ist die "Sovereign Identity" physisch vom System getrennt.

---
**Sources:**
*   `/home/Knowledge-Pipeline/raw/_duplikate/Claude-NMS v4.2 sovereign identity implementation strategy.md`
*   `/home/Knowledge-Pipeline/raw/_duplikate/Gemini-NixOS Homelab Architecture Review (1).md`
