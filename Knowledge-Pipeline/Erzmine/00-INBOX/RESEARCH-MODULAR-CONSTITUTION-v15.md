# [RESEARCH-MODULAR-CONSTITUTION] v15.0 Pre-Flight
# Status: Stage 1 (Erz) | Date: March 2026

## 1. Modular System Prompts (LLM Best Practices)
Die Recherche nach "Best practices for modular system prompts" ergab folgende architektonische Leitplanken für die v15.0 Verfassung:

### A. Orchestrator-Specialist Pattern
- **Problem:** Eine riesige GEMINI.md bläht das Context-Window auf und führt zu "Context Drift" (die KI vergisst Anweisungen aus der Mitte des Dokuments).
- **Lösung:** Ein "Orchestrator" (Core-Prompt) lädt nur die grundlegenden Guardrails (z.B. Pfadreinheit, SSoT-Version). Detail-Wissen (wie das Storage-Tiering oder Jellyfin-Details) wird in **Specialist-Prompts** (Sub-Module) ausgelagert und nur bei Bedarf per RAG oder spezifischem Tool-Aufruf geladen.

### B. Separation of Concerns (Die Split-Strategie)
Die monolithische v14.x Verfassung sollte in v15.0 wie folgt gesplittet werden:
1. **`GEMINI-CORE.md` (Statuten):** Persona, absolute Verbot-Regeln, Pfadreinheit, UDS-Zwang, Aviation-Grade Mindset. (Immer im Kontext).
2. **`MODULE-STORAGE.md`:** Tier A/B/C/D Logik, MergerFS, Smart USB Indexing.
3. **`MODULE-NETWORK.md`:** Caddy Ingress, Vault-Isolierung (VPN vs. Exposed), nftables Kill-Switch.
4. **`MODULE-APPS.md`:** Spezifische Anwendungsregeln (Pocket-ID Passkeys, Matrix, n8n).

### C. XML Tagging & Priority Signaling
- Um die Struktur für das LLM lesbarer zu machen, sollten in den Modulen XML-Tags (`<guardrails>`, `<architecture>`) verwendet werden. Modalverben ("MUST", "VERBOTEN") erzwingen Compliance.

## 2. Jellyfin Metadata Separation (SSD vs. HDD)
Die Vorgabe lautet: Metadaten auf Tier B (SSD), Media auf Tier C (MergerFS HDD).
In der nativen Linux-Struktur von Jellyfin (bzw. in unserem NixOS Container) sieht das so aus:

- **Media Files:** Liegen auf `/mnt/media` (Tier C, MergerFS). Die HDDs können im Sleep bleiben.
- **Data & Metadata:** Liegen standardmäßig in `/var/lib/jellyfin/` (welches `data` und `metadata` Ordner enthält).
- **Lösung in v14.x:** Wir haben in der `vault-exposed.nix` bereits `/var/lib/jellyfin` an `/persist/jellyfin` (Tier A, NVMe) gebunden. Damit sind Media und Metadata bereits physisch auf getrennten Platten!
- **Optimierung für Tier B (SSD):** Wenn wir die NVMe schonen wollen und die Metadaten explizit auf die SATA-SSD (Tier B) legen wollen, passen wir den `bindMount` im Container an:
  ```nix
  "/var/lib/jellyfin/metadata" = {
    hostPath   = "/mnt/cache/jellyfin-metadata"; # Tier B
    isReadOnly = false;
  };
  ```
- **Ergebnis:** Jellyfin kann blitzschnell Cover und Beschreibungen aus dem Cache laden, ohne dass eine einzige Tier C HDD hochdreht. Die HDD weckt erst beim Abspielen (`fatrace` wird das bestätigen).

## 3. Tool Sharpening (MCP Audit)
Alle 14 MCP-Server-Manifeste (`GEMINI.md` in `.gemini/extensions/` und `/root/`) wurden iterativ um die Sektion "IX. AVIATION-GRADE BEHAVIORAL RULES (v14.x)" erweitert:
- SSoT Binding (v14.x)
- UDS Priority over TCP
- Hardware Abstraction (Labels)
- USB Transient Automount
- Metadata/Media Split
- No Path Guessing
