# GEMINI.md – Das Master-Manifest (v9.0)
# Status: Definitives SSoT | Stand: März 2026 | Supersedes: v8.0

═══════════════════════════════════════════════
## 0. DIE DREIFALTIGKEIT DER PFADE
═══════════════════════════════════════════════

1. **WERKSTATT:** `/home/Werkstatt/` 🟢
   - **Zweck:** Nur reine NixOS-Strukturdateien (.nix).
   - **Reinheitsgebot:** Keine Scripte, keine Dokumentation, kein Legacy-Müll.
   - **Arbeitsweise:** Chirurgie am lebenden System. Jede Änderung wird per Git committet.

2. **ALMANACH:** `/home/Knowledge-Pipeline/Almanach/` 🟢
   - **Zweck:** "Heilige Handwerkerbibel" (Veredeltes Wissen).
   - **Inhalt:** ADRs, GUIDEs, Service-Docs, Roadmap, Scripts (ausführbares Wissen).
   - **Wachstums-Gesetz:** Wissen wird NIEMALS gelöscht. Veraltetes wird als `[DEPRECATED]` markiert. Fehlentscheidungen werden als `[REJECTED]` begründet (z.B. "Warum kein CrowdSec").

3. **ERZMINE (RAW):** `/home/Knowledge-Pipeline/Erzmine/` 🟤
   - **Zweck:** Rohdaten-Pipeline (Das ungeschmolzene Golderz).
   - **`00-INBOX/`**       : Übergabeort für neue Quellen/Dateien.
   - **`01-PROCESSING/`**  : Ort der Analyse und "Einschmelzung".
   - **`02-ARCHIVE/`**     : Ausgewrungene Rohdaten mit Referenz-IDs.
   - **`03-RESOURCES/`**   : Externe Quellen-Manifeste und statische Assets.

═══════════════════════════════════════════════
## I. PATTERN-MINING & VEREDELUNG (GOLD-NUGGETS)
═══════════════════════════════════════════════

Wenn eine externe Quelle (GitHub, Blog, Liste) übergeben wird:

1. **PHASE – SCHÜRFEN (Exploration):**
   - Repository nach Perlen und architektonischen Ideen durchsuchen.
   - Fundstellen mit `context7` und `Web Search` auf Validität prüfen.

2. **PHASE – ROADMAP (Planung):**
   - Valide Punkte in die interne Roadmap aufnehmen.
   - Dem Nutzer vorstellen (GO/NO-Entscheidung).

3. **PHASE – SPEICHERN (Erzmine):**
   - Rohwissen in `Erzmine/03-RESOURCES/` ablegen.

4. **PHASE – GIESSEN (Almanach):**
   - Nur das Beste ("Goldbarren") in den Almanach überführen.
   - Wissen mit IDs markieren (z.B. `[NUGGET-XXX-001]`).

═══════════════════════════════════════════════
## II. UNVERÄNDERLICHE PRINZIPIEN (REINHEITSGEBOT)
═══════════════════════════════════════════════

- **Binary-Effizienz:** Go/Rust/C Single-Binaries gewinnen immer.
- **Kein Bleeding Edge:** Nur stabile Best-Practices (kein Denix, kein experimenteller Kram).
- **Kein Legacy-Dreck:** Cronjobs, generische Treiber oder Docker sind strengstens verboten.
- **Dendritic-Pattern:** Eine Datei = Ein Feature.

═══════════════════════════════════════════════
## III. MCP-SERVER VALIDIERUNG
═══════════════════════════════════════════════

Missionskritische Werkzeuge:
- `context7`        : Primäre Quelle für Nix-API (Zwingend vor jeder .nix Änderung).
- `nixos`           : Suche in Optionen/Paketen.
- `open-websearch`  : Live-Trends und Security-Checks.
- `cloudflare`      : Ingress-Steuerung.

═══════════════════════════════════════════════
## IV. ANTI-HALLUZINATIONS-GESETZ
═══════════════════════════════════════════════

- **Beweispflicht:** Erfolg wird durch `ls -la` oder System-Test belegt.
- **Transparenz:** Vor jeder Aktion den Plan kurz (1 Satz) erläutern.
- **Keine Platzhalter:** Dokumente werden immer vollständig und präzise verfasst.

## Gemini Added Memories
- MCP-Server sind ausschließlich temporäre Werkzeuge für den Agenten zur Wissensextraktion und Code-Analyse. Sie dürfen niemals in die produktive NixOS-Systemkonfiguration (configuration.nix) aufgenommen werden. Ausnahme: Home Assistant MCP. Diese Trennung ist für die System-Purity (Aviation-Grade) essenziell.
