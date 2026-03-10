# [ADR-037]: Containerized Service Architecture (The Vault)
# ID: [ADR-037] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir nutzen „Defense-in-Depth“. Ein Angreifer müsste zwei Schlösser gleichzeitig knacken: Zuerst die Absicherung innerhalb des Programms und dann den Ausbruch aus dem virtuellen Tresorraum (Container). 

## 2. Technical Layer (Spezifikation)
- **Technik:** `containers.<name>` (basiert auf `systemd-nspawn`).
- **Isolation:** Jeder Container erhält ein eigenes virtuelles Interface (`ve-<name>`) und eine eigene IP-Adresse.
- **Innere Härtung:** Innerhalb des Containers werden alle Dienste weiterhin mit `ProtectSystem`, `PrivateTmp` etc. gehärtet.
- **State-Management:** Die `/var/lib` Ordner der Dienste werden vom Host-System in den Container gemountet (Bind-Mount), damit sie unsere **Impermanence** und **API-Injection** Regeln (ADR-034) nutzen können.

## 3. Reasoning Layer
- **Warum?** Maximale Sicherheit bei minimalem Overhead (geteilter Nix-Store).
- **Souveränität:** Der gesamte Tresorraum wird deklarativ in der `flake.nix` definiert. Kein manuelles „Händeschütteln“ mit Docker-Images nötig.

---
> [SOURCE]: Architektur-Diskussion „Safe-im-Tresor“ (10.03.2026)
