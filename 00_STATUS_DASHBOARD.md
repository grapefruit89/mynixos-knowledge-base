---
title: 📊 Aviation-Grade Status Dashboard (Architecture Debt Monitor)
category: architecture/audit
status: [ACTIVE-MAINTENANCE]
sources: [Interne Bestandsaufnahme 09.03.2026]
---

# 📊 Status Dashboard: Architecture Debt & SSoT Mapping

Dieses Dashboard überwacht den Zustand der Knowledge-Pipeline. Es dient zur Identifikation von Redundanzen, veralteten Versionen und "Phantompfaden".

## 🔵 Erledigte Aufgaben (Cleanup) (Priority To-Do)
1. **Deduplizierung Cluster Dendritic:** Mergen von `Architecture-NIXHOME-Dendritic-Structure.md` in `GUIDE-Dendritic-Modularization.md`.
2. **Archivierung Monster-Dateien:** Verschieben von `server_knowledge_detailed.md` (19MB) nach `/raw/archive/`.
3. **Link-Fixing:** Korrektur aller Phantompfade im Master-Index.

## 🟢 Dokumenten-Status (Top-Level)

| Datei | Thema | Version | Status | Supersedes |
| :--- | :--- | :--- | :--- | :--- |
| `00_GOLDEN_HANDBOOK_...` | Master-Index | v1.0 | ✅ AKTIV-SSoT | `00_MASTER_INDEX.md` |
| `GUIDE-Dendritic-...` | Modularisierung | v6.7 | ✅ AKTIV-SSoT | `Architecture-NIXHOME-...` |
| `GUIDE-Seven-Quality-...` | SRE Standard | v1.0 | ✅ AKTIV-SSoT | - |
| `ADR-001-Lightweight-...` | Identity Choice | v1.0 | ✅ AKTIV-SSoT | - |
| `Strategy-Determinate-...` | Enterprise Nix | v3.0 | ✅ AKTIV-SSoT | `v1`, `v2` Strategien |
| `Architecture-NIXHOME-...` | Dendritic Structure | v4.2 | 🗑️ SUPERSEDED | - |
| `server_knowledge_...` | Roh-Wissen | - | 📦 ROHMATERIAL | - |

## 📂 Struktur-Audit
- **Eigene Synthesen:** 📂 `/docs/GUIDE-*`, `/docs/Strategy-*`, `/docs/adr/*`
- **Rohmaterial (Mining):** 📂 `/docs/mighty-*`, `/docs/det-*`, `/docs/nixcomm-*` → *Verschiebung nach /raw/sources/ geplant.*

---
*Letzter Audit: 09.03.2026 01:45*
