# 🗺️ Master-Roadmap: Vom Golderz zum Goldbarren
# Status: Aktiv | Stand: 10.03.2026

## 🟢 1. Wissens-Veredelung (Erzmine -> Almanach)
Hier tracken wir Rohdaten, die noch in die "Heilige Handwerkerbibel" gegossen werden müssen.

- [x] **Impermanence-Strategie** [NUGGET-NIX-001]
  - Status: Extrahiert in Processing.
  - Ziel: Erstellung von ADR-010 im Almanach.
- [x] **MicroVM-Isolation** [NUGGET-NIX-001]
  - Status: Extrahiert in Processing.
  - Ziel: Erstellung von ADR-011 im Almanach.
- [x] **Privacy Guides Standards** [NUGGET-PRIV-001]
  - Status: In Resources hinterlegt.
  - Ziel: Extraktion von Souveränitäts-Baselines.
- [x] **Awesome-Nix Ecosystem Scan** [NUGGET-NIX-001]
  - Status: Veredelt in ADR-020.
  - Ziel: Identifikation von weiteren SRE-Tools.
- [ ] **Aviation-Grade Productivity Scan** [NUGGET-PROD-001]
  - Status: Guide erstellt (Memos & Dagu).
  - Ziel: Evaluation für Layer 30/50.

## 🟡 2. Die Werkstatt (System-Guss)
Hier halten wir fest, welche architektonischen Korrekturen an den .nix Dateien nötig sind.

- [x] **Build-Reparatur (my.services Options)** [CENTRAL-OPTS]
  - Problem: System aktuell nicht baubar, da Modul-Optionen in my.services.* fehlen.
  - Plan: Fehlende Options-Definitionen in 00-core zentralisieren oder in Module rückführen.
- [x] **SSH-Härtung (ADR-009)** [CA-KEYS]
  - Plan: Umsetzung von ADR-009 in der ssh.nix.
- [x] **SRE-Toolbox Integration** [ADR-020]
  - Plan: Aufnahme der verifizierten Tools in shell.nix.
- [x] **Gatus-Konfiguration** [ADR-022]
  - Ziel: Health-Checks für alle aktiven Services definiert.
- [ ] **Unified Alerting Integration** [ADR-025]
  - Ziel: Integration von ntfy-sh in Gatus und System-Services.
- [ ] **Systemd Socket Activation Scan** [NUGGET-SRE-009]
  - Ziel: Identifikation und Umstellung von ressourcenhungrigen Diensten auf on-demand Start.
- [ ] **STT Workflow (Whisper.cpp)** [ADR-029]
  - Ziel: Implementierung der Path-Unit gesteuerten Transkription in Layer 60.

## 🚀 3. SRE-MEILENSTEINE (Aviation-Grade Upgrade)
- [ ] **sops-nix Migration [PRIO 1]**
  - Ziel: Git-native Geheimnisverwaltung. Ablösung der manuellen `.env` Dateien.
- [ ] **Impermanence Strategie [PRIO 2]**
  - Ziel: Root-on-tmpfs für einen sauberen State bei jedem Boot.
- [ ] **disko & Storage Tiering [STRATEGY]**
  - Ziel: Kombiniertes Setup von deklarativer Partitionierung und ABC-Tiering (NVMe/HDD).

## 🟤 4. Archiv-Bereinigung (Erzmine Archiv)
- [ ] **Referenz-ID Mapping**
  - Ziel: Alle alten Chatlogs in 02-ARCHIVE mit IDs versehen, damit wir wissen, welches Wissen daraus in den Almanach floss.
