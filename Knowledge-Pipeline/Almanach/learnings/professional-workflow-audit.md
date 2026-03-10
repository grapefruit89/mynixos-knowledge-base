---
title: "Workflow Audit: Professional Engineering Standard"
category: "learnings"
tags: [workflow, audit, productivity, ai-collaboration]
date: 2026-03-08
source: "architectural-analysis-session-0803"
status: "verified-substance-definitive"
---

# 🧠 LEARNING: DER PROFESSIONALISIERTE ARBEITSSTIL (V1.0)

Dieses Dokument definiert den Standard für die Zusammenarbeit zwischen dem Nutzer (Architect) und Gemini (Tool).

---

## 🏗️ 1. USER LAYER: DIE PHILOSOPHIE (KISS)
Arbeite präzise, melde physischen Vollzug und verliere niemals ein Detail. Wir bauen ein digitales Gedächtnis, das Stress reduziert und Zuverlässigkeit erhöht.

---

## 🛠️ 2. TECHNICAL LAYER: OPERATIVER STANDARD

### A. Das Such-Mandat
Bevor eine Synthese stattfindet, ist ein tiefer Grep-Lauf über ALLE Rohdaten-Verzeichnisse (`/raw/chats/`, `/raw/docs/`, `_duplikate/`) zwingend.

### B. Die physische Beweispflicht
Jede Dateimanipulation muss durch folgende Sequenz validiert werden:
1. `write` (via Python-Generator).
2. `ls -l` (Existenz- und Größenprüfung).
3. `head/tail` (Inhaltsprüfung).

### C. Das Drei-Layer-Prinzip
Keine Dokumentation ohne KISS, Technical und Reasoning Layer.

---

## 📜 3. REASONING LAYER: HERLEITUNG
Die Professionalisierung zielt darauf ab, die KI von einem "Erzähler" zu einem "Präzisions-Werkzeug" zu transformieren. Durch die Verankerung dieser Regeln im `GEMINI.md` wird die kognitive Last des Nutzers (das ständige Korrigieren der KI) minimiert.

---

## ✅ VERBESSERUNGS-BACKLOG
- [ ] Implementierung eines automatischen Meta-Data Scanners vor jedem Schreibvorgang.
- [ ] Integration von `nix-eval` zur Live-Syntax-Prüfung bei jeder Dokument-Erstellung.
