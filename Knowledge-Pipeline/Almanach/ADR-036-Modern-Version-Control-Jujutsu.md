# [ADR-036]: Modern Version Control (Jujutsu - jj)
# ID: [ADR-036] | Status: PROPOSED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir führen `jj` als modernes Frontend für `git` ein. Es hilft uns, Fehler in der Werkstatt zu vermeiden, indem es jeden Bearbeitungsschritt automatisch sichert. Wir können weiterhin zu GitHub pushen wie bisher.

## 2. Technical Layer
- **Tool:** `pkgs.jujutsu` (Rust 🦀).
- **Format:** Kompatibel mit bestehenden Git-Repositories.
- **Workflow:** `jj git fetch` -> Bearbeiten -> `jj git push`.
- **Besonderheit:** Kein manuelles `git add` oder `git commit` mehr nötig für lokale Snapshots.

## 3. Reasoning Layer
- **Warum?** Git-Kommandos sind oft kryptisch und führen zu Datenverlust bei Fehlbedienung. `jj` bietet ein "Aviation-Grade" Sicherheitsnetz für die Code-Entwicklung.

---
> [SOURCE]: https://github.com/martinvonz/jj
