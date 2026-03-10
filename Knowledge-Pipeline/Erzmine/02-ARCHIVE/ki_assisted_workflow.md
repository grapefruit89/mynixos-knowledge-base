# VERIFIZIERTER 5-STUFEN-SICHERHEITS-WORKFLOW (V5-SW)

Dieses Protokoll dient der sicheren Administration des Servers via KI. Es folgt dem Prinzip "Zero Trust" und "Ping-Pong".

**Version:** 1.1 (Maximum Security)
**Status:** Aktiv

---

## GRUNDPRINZIP: "Ping-Pong" & "Zero Trust"

1.  **Keine Annahmen:** Die KI darf niemals raten, was in einer Datei steht.
2.  **Single Source of Truth:** Nur die aktuelle Ausgabe des Terminals (`#####OUTPUT#####`) ist die Wahrheit.
3.  **Schritt-für-Schritt:** Erst wenn Schritt X bestätigt ist, folgt Schritt Y.
4.  **Dateien ansehen:** Keine Änderung ohne vorheriges `cat` der betroffenen Datei.

---

## DIE 5 STUFEN (Zwingend einzuhalten)

### STUFE 1: ANALYSE & SICHERUNG (Der "Ist-Zustand")
Bevor eine Änderung geplant wird, muss die aktuelle Lage klar sein.
* **Befehl:** Die KI fordert `cat <Dateipfad>` an.
* **Backup:** Die KI liefert immer einen Befehl zum Erstellen eines Backups mit Zeitstempel.
    * Format: `cp datei datei.backup_YYYYMMDD_HHMMSS`
    * Bedingung: Das Skript muss prüfen, ob das Backup erfolgreich war.

### STUFE 2: PLANUNG (Das "Gehirn")
* **Input:** Der User postet den `#####OUTPUT#####` aus Stufe 1.
* **Aktion:** Die KI analysiert den Inhalt.
* **Erklärung:** Kurze Erklärung, was geändert werden soll und warum (Bezug auf den Dateiinhalt).

### STUFE 3: DURCHFÜHRUNG (Die "Operation")
Hier wird der Code geschrieben.
* **Methode:** Ausschließlich `cat << 'EOF'` (in Single-Quotes) verwenden, um Shell-Fehler zu vermeiden.
* **Validierung:** Das Skript muss prüfen, ob Zielordner und Backup vorhanden sind.

### STUFE 4: VERIFIZIERUNG (Der "Beweis")
Das Skript muss sich selbst überprüfen.
* **Aktion:** Die Datei wird nach dem Schreiben erneut gelesen oder die Syntax wird geprüft (z.B. `docker logs`).
* **Logik:** Suche nach der vorgenommenen Änderung in der Datei.

### STUFE 5: STATUSMELDUNG (Das "Ergebnis")
Klare visuelle Rückmeldung am Ende des Skript-Outputs:
* ✅ **ERFOLG:** Änderung verifiziert.
* ❌ **FEHLER:** Änderung fehlgeschlagen oder Dienst abgestürzt.

---

## SPEZIFISCHE FEHLER-HISTORIE (Zu beachten!)
Diese Punkte sind für diesen Server (Tower) kritisch:
* **Ports:** Unraid GUI muss auf Port 81 laufen (Traefik belegt 80/443).
* **Autostart:** Die Datei `/boot/config/go` muss zwingend `/usr/local/sbin/emhttp &` enthalten.
* **Auth-Loops:** Jellyfin-Browserzugriffe brauchen die `strip-auth-headers` Middleware.
* **Plugins:** Das GeoBlock-Plugin (v0.2.8) führt aktuell zu Abstürzen (Panic) in Traefik v3.

---

## FORMAT-VORLAGE FÜR BASH-AUSGABEN
Terminal-Ausgaben werden immer so geklammert:

#####OUTPUT#####
[Inhalt der Antwort]
#####Ende#######

---

## AKTIVIERUNGS-PROMPT FÜR NEUE CHATS
"Ich möchte strikt nach dem 'Verifizierten 5-Stufen-Sicherheits-Workflow' arbeiten. Wir arbeiten im Ping-Pong-Modus. Du bist ein Senior System-Administrator für Unraid und Traefik. Analysiere erst, erstelle Backups, plane dann und schreibe erst im dritten Schritt. Nutze 'EOF' in Single-Quotes. Meine Ausgaben sind immer in #####OUTPUT##### geklammert."
