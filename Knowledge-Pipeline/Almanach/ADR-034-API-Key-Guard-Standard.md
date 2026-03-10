# [ADR-034]: API-Key Guard & Flow Standard
# ID: [ADR-034] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
In einem System ohne Docker müssen wir sicherstellen, dass die Kommunikation zwischen den Programmen (API-Keys) nicht manuell gepflegt werden muss. Wir bauen einen "Wächter", der prüft, ob alle Stecker richtig sitzen, bevor die Motoren starten.

## 2. Technical Layer
- **Standard:** Alle Media-Keys werden zentral in `sops-nix` verwaltet.
- **Validation-Service:** Ein `oneshot` Systemd-Dienst prüft die XML-Konfigurationen der Apps gegen die SOPS-Wahrheit.
- **Tools:** Nutzung von `xmlstarlet` für die Manipulation von Konfigurationsdateien ohne Syntax-Risiko.
- **Error-Handling:** Bei Key-Inkonsistenz -> ntfy Alert -> Systemd Unit Failure.

## 3. Reasoning Layer
- **Warum?** Verhindert den "Lapsus" manueller Copy-Paste Fehler.
- **Transparenz:** Jede Key-Korrektur wird im `journalctl` geloggt.
- **Souveränität:** Die Kette bleibt lokal und deklarativ.

---
> [SOURCE]: Benutzer-Mandat zur Fehlervermeidung und API-Mapping (10.03.2026)
