# [ADR-026]: Workflow-Automation (Dagu vs. systemd)
# ID: [ADR-026] | Status: REJECTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir haben evaluiert, ob wir für wiederkehrende Aufgaben und Automatisierungen (Backups, Skripte, Updates) das Tool **Dagu** (einen modernen Cron-Ersatz mit visueller Oberfläche) einführen sollten. 

## 2. Technical Layer (Spezifikation)
- **Evaluiertes Tool:** `pkgs.dagu` (Go-Native Workflow Engine).
- **Zweck:** Visuelle Darstellung und Verkettung von Aufgaben (Directed Acyclic Graphs).
- **Entscheidung:** Das Tool wird **nicht** in die Werkstatt übernommen.

## 3. Reasoning Layer (ADR)
- **Warum REJECTED?** Auf einem Aviation-Grade NixOS-System ist `systemd` (mit `.service`, `.timer` und `.path` Units) der absolute Goldstandard. `systemd` löst bereits alle Probleme der Abhängigkeiten (`Wants=`, `After=`) und der Zeitsteuerung.
- **Vermeidung von Ballast:** Ein zusätzlicher Daemon wie Dagu würde eine weitere Abstraktionsschicht einführen, die außerhalb der nativen Nix-Deklaration lebt. 
- **Ersatz-Strategie:** Wir nutzen rein native `systemd` Mechanismen und ergänzen diese um `ntfy` (ADR-025), um Alarme bei Fehlschlägen (`OnFailure=`) zu erhalten.

---
> [SOURCE-NUGGET]: Evaluierung aus dem "Awesome-Selfhosted" Scan (10.03.2026).
> [WISSENS-ARCHIV]: Dieses Dokument dient dem Erhalt des Wissens. Dagu ist ein großartiges Tool für Nicht-NixOS-Systeme, aber hier architektonischer Ballast.
