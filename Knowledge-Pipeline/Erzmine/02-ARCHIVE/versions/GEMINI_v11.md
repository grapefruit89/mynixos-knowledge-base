# GEMINI.md – Die Master-Verfassung (v10.0)
# Status: DEFINITIVES SSoT | Stand: März 2026 | [SUPERSEDED]: v9.0

═══════════════════════════════════════════════
## 0. DIE ERWEITERTE DREIFALTIGKEIT DER PFADE
═══════════════════════════════════════════════

1. **WERKSTATT:** `/home/Werkstatt/` 🟢
   - **Zweck:** Nur reine NixOS-Strukturdateien (.nix).
   - **Reinheitsgebot:** Keine Scripte, keine Dokumentation. Jede Änderung wird per Git committet.

2. **ALMANACH:** `/home/Knowledge-Pipeline/Almanach/` 🟢
   - **Zweck:** "Heilige Handwerkerbibel" (Veredeltes Wissen).
   - **Gedächtnis:** `/home/Knowledge-Pipeline/.vectorstore/` (RAG-Index).
   - **Wachstums-Gesetz:** Wissen wird NIEMALS gelöscht. Veraltetes ist als `[DEPRECATED]` markiert.

3. **ERZMINE (RAW):** `/home/Knowledge-Pipeline/Erzmine/` 🟤
   - **Zweck:** Rohdaten-Pipeline (Das ungeschmolzene Golderz).
   - **Souveränitäts-Speicher:** `/persist/` (Dauerhafte Daten, Secrets, DBs).

═══════════════════════════════════════════════
## I. DIE HARDWARE-KONSTITUTION (Q958 FAKTEN)
═══════════════════════════════════════════════

Die physische Spezifikation des Fujitsu Q958 ist das oberste Gesetz. Jede Abweichung ist ein kritischer Systemfehler.

- **Tier A:** Samsung NVMe (M.2 Main) -> **OS / ZFS / State / /persist**.
- **Tier B:** Apacer SSD (M.2 WLAN Slot) -> **Download-Cache / Transcoding**.
- **Tier C:** SATA HDDs (JBOD) -> **Bulk Media / MergerFS**.

═══════════════════════════════════════════════
## II. STORAGE & ATOMICITY GESETZE
═══════════════════════════════════════════════

- **MergerFS Mandat:** Zwingende Nutzung von `category.create=epmfs`.
- **Atomic Move Law:** Alle Verschiebungen zwischen Tier B (Downloads) und Tier C (Media) MÜSSEN zero-copy Operationen sein (gleiche physische Platte via .staging).
- **No-RAID Mandat:** RAID, SnapRAID oder Stripping sind strengstens verboten. Daten-Souveränität erfolgt durch Backups, nicht durch lokale Redundanz.

═══════════════════════════════════════════════
## III. DER SICHERHEITS-VAULT (NOTHAMMER)
═══════════════════════════════════════════════

- **Container-Standard:** NixOS Container (nspawn) sind die EXCEPTION, reserviert für exponierte Dienste (Jellyfin, Audiobookshelf) oder striktes VPN-Confinement.
- **Kill-Switch:** Container für VPN-Traffic MÜSSEN `privateNetwork = true` nutzen und das physische/virtuelle VPN-Interface (wg-privado) exklusiv zugewiesen bekommen.
- **Leak-Protection:** Ohne aktives Interface darf keine Netzwerk-Hardware im Container existieren.

═══════════════════════════════════════════════
## IV. RAG-FIRST OPERATIONS (AGENTEN-LOGIK)
═══════════════════════════════════════════════

- **Query-Zwang:** Vor jeder Code-Generierung oder Architektur-Beratung MUSS der RAG-Vektorstore (`gemini_cli_query_tool`) konsultiert werden.
- **Abgleich-Pflicht:** Almanach (Gesetze) vs. Erzmine (Nuggets) müssen bei jedem Schritt cross-referenziert werden.
- **Beweispflicht:** Jede Aktion muss durch physische Prüfung (`ls -la`, `cat`) belegt werden.

═══════════════════════════════════════════════
## V. RECONCILIATION LOG (FIXES v10.0)
═══════════════════════════════════════════════

- **Tier B/C Korrektur:** Tier B ist nun final als SSD (WLAN Slot) und Tier C als HDD definiert.
- **VPN-Wandel:** `nixarr` (Namespace-Scripts) wurden durch das `Media-Vault` (Container) Modell ersetzt.
- **Policy Fix:** MergerFS Policy von `ff` (First Found) auf `epmfs` (Existing Path Most Free Space) korrigiert, um Atomic Moves zu ermöglichen.
- **Memory-Fix:** Integration des RAG-Tools als primäre Wissensquelle des Agenten.
