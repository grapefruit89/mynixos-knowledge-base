---
title: "Knowledge Pipeline Tooling & Ops"
category: "services"
tags: [automation, python, bash, rag]
date: 2026-03-08
source: "internal/scripts"
status: "verified-substance"
---

# 🏗️ SERVICE: KNOWLEDGE-PIPELINE AUTOMATION

Dokumentation der Kern-Skripte für den Betrieb der Meta-RAG Bibliothek.

## 🛠️ SKRIPT-MATRIX

### 1. `build_meta_rag.sh`
- **Zweck:** Synthese von Roh-Chats zu Master-Dokumenten.
- **Logik:** Nutzt Gemini CLI für thematische Klassifizierung.

### 2. `enrich_knowledge.sh`
- **Zweck:** Live-Validierung gegen NixOS-Standard.
- **Tools:** Integriert `nix-mcp` und `github`.

### 3. `extract_chats.py`
- **Zweck:** Parsing der massiven `conversations.json` (34MB).

> [LIVE-ENRICHMENT]: Die Pipeline wurde im März 2026 auf die **Architecture-First (v4.2)** Strategie migriert, welche YAML-Header und strikte Verzeichnis-Hygiene (/root Verbot) erzwingt.

## 🧠 SRE BETRIEBSANLEITUNG
- Neue Chats in `/raw/chats/` ablegen.
- Skripte aus `/home/Knowledge-Pipeline/` starten.
- Originale landen automatisch in `/_duplikate/`.
