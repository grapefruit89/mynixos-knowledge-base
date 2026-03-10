# GEMINI.md – Die Master-Verfassung (v12.0)
# Status: SUPREME SSoT | Stand: März 2026 | [SUPERSEDED]: v7.0, v10.0, v11.0

# LLM-METADATA-START
# PLATINUM_ID: 0.00
# FILE_NAME: GEMINI.md
# PURPOSE: MASTER PROJECT CONTEXT & CONSTITUTION (v12.0 - Universal Platinum)
# EXECUTION: Reference only (READ-ONLY for AI agents)
# DEPENDENCIES: RAG-Vectorstore, Nix-Flakes
# CONTEXT_TRIGGERS: Project root, architecture, standards, workflow, sovereignty
# LAST_MODIFIED: 2026-03-10
# RISK_LEVEL: CRITICAL
# LLM-METADATA-END

═══════════════════════════════════════════════
## 0. DIE UNIVERSELLE DREIFALTIGKEIT DER PFADE
═══════════════════════════════════════════════

1. **WERKSTATT:** `/home/Werkstatt/` 🟢
   - **Zweck:** Reine NixOS-Strukturdateien (.nix).
   - **Reinheitsgebot:** Keine imperativen Skripte, keine Dokumentation. Alles ist deklaratives Nix.
   - **Mandat:** Strikte Portabilität. Keine maschinenspezifischen Bus-Adressen im Core.

2. **ALMANACH:** `/home/Knowledge-Pipeline/Almanach/` 🟢
   - **Zweck:** "Heilige Handwerkerbibel" (Veredeltes Wissen & Gesetze).
   - **Gedächtnis:** `/home/Knowledge-Pipeline/.vectorstore/` (RAG-Index).

3. **ERZMINE (RAW):** `/home/Knowledge-Pipeline/Erzmine/` 🟤
   - **Zweck:** Rohdaten, Backups & Souveränitäts-Speicher (`/persist/`).

═══════════════════════════════════════════════
## I. SYSTEM PHILOSOPHY (Sovereignty & Associative Mining)
═══════════════════════════════════════════════

- **Souveränität (ADR-032):** Wir lehnen externe Abhängigkeiten (GitHub) während des Builds ab. Alle Quellen (nixpkgs, sops-nix) werden lokal in Forgejo gespiegelt.
- **SOPS-Purity:** Flake-Inputs sind heilig. Niemals NIX_PATH (`<sops-nix/modules/sops>`) nutzen. Alles MUSS über die rein deklarative Flake-Registry (`inputs.sops-nix.nixosModules.sops`) geladen werden.
- **Undefined Options Guard:** Niemals Optionen (`config.my.*`) aufrufen, ohne sie vorher über `lib.mkOption` explizit zu definieren.

### NEW CORE LAW: ADR-040 – THE LAW OF ASSOCIATIVE MINING
Ein technischer Begriff ist NIEMALS eine Insel.
- Jeder Begriff (Seed) löst eine rekursive Suche nach seinen technischen "Satelliten" (Abhängigkeiten) aus.
- **REKURSIONS-REGEL:** Werden Konzepte wie 'MergerFS' modifiziert, MÜSSEN autonom die Randbedingungen verifiziert werden (z.B. FUSE-Berechtigungen, Inode-Preservation, Mount-Reihenfolge, Group-Access).
- Jedes Scheitern beim Mapping des technischen Ökosystems eines Konzepts ist ein Verstoß gegen die v12.0 Verfassung.

═══════════════════════════════════════════════
## II. UNIVERSAL STORAGE (Role-Based Tiering & Atomic Protocol)
═══════════════════════════════════════════════

Hardware-Slots sind `[DEPRECATED]`. Das System operiert auf Basis von **Disk-Labels**, um ISO-Portabilität zu garantieren.

- **Tier A (Core):** Label `DISK_SYSTEM` -> **ZFS / OS / State / /persist**.
- **Tier B (Cache):** Label `DISK_CACHE` -> **ext4 / Transcoding / Downloads**.
- **Tier C (Bulk):** Label `DISK_STORAGE_*` -> **ext4 (JBOD via MergerFS)**.

**STORAGE & ATOMICITY GESETZE:**
- **MergerFS Mandat:** Zwingende Nutzung von `category.create=epmfs`.
- **Atomic Move Law:** Alle Verschiebungen zwischen Tier B (Downloads) und Tier C (Media) MÜSSEN zero-copy Operationen sein (erzwungen durch physische Platten-Symmetrie via `.staging` Ordner).
- **No-RAID Mandat:** RAID, SnapRAID oder ZFS-Pooling für Medien sind global verboten. Jede Platte ist autonom.

═══════════════════════════════════════════════
## III. SECURITY & THE VAULT (Container Isolation & VPN Kill-Switch)
═══════════════════════════════════════════════

- **Hardening-Score:** Systemd-Security MUSS einen Score von < 4.0 erzielen. Wir nutzen rigoros `DynamicUser=true`, `ProtectSystem=strict`, `PrivateTmp=true` und `RestrictAddressFamilies`.
- **Unix Domain Sockets:** Wo immer möglich (z.B. Caddy <-> SSO/PocketID), sind lokale TCP-Ports verboten. Es MÜSSEN Unix Domain Sockets genutzt werden, um Dateisystem-Berechtigungen zur Netzwerk-Absicherung zu nutzen und Lateral Movement zu verhindern.
- **Der Nothammer (Container-Standard):** NixOS Container (nspawn) sind die Ausnahme, reserviert für exponierte Dienste oder striktes VPN-Confinement.
- **Kill-Switch (VPN Vault):** Container für VPN-Traffic MÜSSEN `privateNetwork = true` nutzen. Das VPN-Interface (wg-privado) wird physisch in den Container durchgereicht. Ein Leak ist ohne Netzwerk-Hardware physikalisch unmöglich.

═══════════════════════════════════════════════
## IV. OPERATION STANDARDS (RAG-First, Purity, Forensic Mapping)
═══════════════════════════════════════════════

- **RAG-First Operations:** Vor Code-Generierung oder Architektur-Beratung MUSS der RAG-Vektorstore (`gemini_cli_query_tool`) konsultiert werden.
- **Forensic Mapping:** Jede Aktion muss den Ist-Zustand (`cat`, `ls -la`) ermitteln und gegen den Almanach abgleichen.
- **Purity-Zwang:** Kein manuelles `sed`, `chmod` oder `chown` im Live-Betrieb. Jede Konfiguration wird ausschließlich über deklaratives Nix gesteuert.

═══════════════════════════════════════════════
## V. ARCHIVE MANDATE & RECONCILIATION LOG
═══════════════════════════════════════════════

Alle älteren Versionen der Verfassung wurden archiviert.
- **Integration 1:** "Unix Domain Sockets" Anforderung (aus Homelab Architecture Review).
- **Integration 2:** "SOPS-Purity & Undefined Options Guard" (aus Projektprüfung).
- **Integration 3:** "Platinum Admin Metadata Headers" (aus gemini_md_v2_1).
- **Integration 4:** "Law of Associative Mining" (ADR-040).
