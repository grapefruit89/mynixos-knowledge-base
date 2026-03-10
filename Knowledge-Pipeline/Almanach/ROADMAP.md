# 🗺️ Master-Roadmap (Aviation-Grade SSoT)
# ID: [ROADMAP-001] | Stand: 10.03.2026 | SSoT Status: ACTIVE

Dieses Dokument ist der einzige Speicher für alle Ideen und Aufgaben. Punkte werden erst gelöscht, wenn sie vollständig in der Werkstatt umgesetzt UND im Almanach dokumentiert sind.

---

## 🔥 1. AKTUELLE DURCHFÜHRUNG (High Priority)

- [x] **Media-Ingress Container Update**
  - Ziel: Caddy leitet Traffic nun korrekt an 10.200.1.2 weiter. (Done)
- [ ] **sops-nix Migration [PRIO 1]**
  - Inventar der Secrets erstellt (Done)
  - Basis-Modul `00-core/secrets.nix` vorbereitet (Done)
  - Guide für manuelle Initialisierung erstellt (Done)
  - *Nächster Schritt:* Du musst die `secrets.yaml` physisch mit deinem Key befüllen.
- [ ] **Impermanence Strategie [PRIO 2]**
  - Konzept "Root-on-tmpfs" im Almanach gesichert (Done)
  - *Nächster Schritt:* Definition aller persistenten Pfade in `modules/00-core/storage.nix`.
- [ ] **Zone-1 Migration (Media Vault) [ADR-039]**
  - Ziel: Zusammenfassung von Radarr, Sonarr etc. in einen gemeinsamen gehärteten NixOS-Container.
- [ ] **SRE-Toolbox Finale [PRIO 3]**
  - `nh` wrapped mit Flake-Pfad (Done)
  - `nix-search-tv` integriert (Done)
  - *Nächster Schritt:* Integration von `osquery` für System-Auditing.
- [x] **API-Key Guard (Pre-Flight Check) [ADR-034]**
  - Ziel: Automatisierte Validierung und Auto-Fix von Media-API-Keys vor Service-Start. (Done)

---

## 🛠️ 2. STRATEGISCHE IMPLEMENTIERUNG (Next Sprints)

- [ ] **Secure Gateway (Warpgate) [ADR-031]**
  - Ziel: SSH und DB-Zugriffe hinter Rust-Bastion mit Session-Recording.
- [ ] **Lanzaboote (Secure Boot Integration) [NUGGET-SRE-016]**
  - Ziel: Signierte Kernel-Images für totale Boot-Integrität.
- [ ] **USB Keyfile Ignition (Zündschlüssel)**
  - Ziel: Physischer USB-Stick als LUKS-Entsperrung für Headless-Reboot.
- [ ] **Local STT Tuning (Whisper.cpp) [ADR-029]**
  - Boilerplate erstellt (Done)
  - *Ziel:* Anbindung an Home Assistant (Wyoming) und Android Keyboard testen.
- [ ] **Sovereign Mirroring [ADR-032]**
  - Ziel: `nixpkgs` lokal in Forgejo spiegeln für 100% Autarkie.
- [ ] **Immich (Memories) Hardening**
  - Ziel: Go-Native Uploader nutzen und RAM-Verbrauch auf Q958 optimieren.

---

## 💾 3. STORAGE & DISKO (In Verbindung mit Tiering)

- [ ] **disko Setup & Storage Tiering**
  - Ziel: Deklarative Festplatten-Struktur für NVMe (Tier A) und HDDs (Tier C).
  - *Wichtig:* Muss mit der Impermanence-Strategie harmonieren.

---

## 🧠 4. PRÜFUNG & RESEARCH (Ideen-Speicher)

- [ ] **Tree-Sitter AST Explorer**
  - Idee: Eigenes Tool `goldmine_extractor.py` für logische Nix-Analyse nutzen.
- [ ] **Jail-Agent Script**
  - Idee: `bwrap` Profile für flüchtige Agenten-Tasks operationalisieren.
- [ ] **Memos Integration (Layer 50)**
  - Idee: Go-Native Micro-Notes für schnellen Wissens-Dump.

---

## 🧹 5. WARTUNG & CLEANUP

- [x] **Skripte sichern:** goldmine_extractor.py etc. nach 00-core/scripts/ verschoben. (Done)
- [x] **Wissens-Kompression:** det-*.md Dateien zu Referenz konsolidiert. (Done)
- [ ] **Konsolidierung Architektur-Files**
  - Ziel: Die drei fast leeren `arch-*.md` Files in das `00_GOLDEN_HANDBOOK` integrieren.
- [ ] **Gatus Health-Checks vervollständigen**
  - Ziel: Alle neu hinzugefügten Dienste (Navidrome, Whisper) überwachen.

---
> [!IMPORTANT]
> Keine Aufgabe darf aus dieser Liste verschwinden, bevor sie nicht "Aviation-Grade" abgeschlossen ist!
