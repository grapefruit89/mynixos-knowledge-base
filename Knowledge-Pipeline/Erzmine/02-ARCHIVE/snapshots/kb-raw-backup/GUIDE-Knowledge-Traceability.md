---
title: Knowledge Traceability (Sourcing Standard)
category: architecture/standard
capabilities: [anti-hallucination, sre-tor-7, source-control]
sources: [Interne Architektur-Entscheidung (ADR), GEMINI.md]
---

# 📚 Knowledge Traceability: Der Sourcing-Standard

In mynixos ist Wissen ohne Quelle ein Bug. Wir folgen dem strikten SRE Tor 7 Protokoll.

## 🏛️ Der YAML-Header Standard
Jedes Dokument (`.md`) MUSS mit einem YAML-Header beginnen, der mindestens folgende Felder enthält:
- `title`: Klarer Name des Nuggets.
- `category`: Einordnung in die Layer-Architektur.
- `sources`: Eine Liste von URLs (GitHub, NixOS Docs, Discourse).

## 🔍 Das Audit-Protokoll
Vor jedem Push zur Knowledge-Base führen wir das Audit-Script aus:
`bash /home/Knowledge-Pipeline/scripts/audit-traceability.sh`

## 🛡️ Anti-Halluzinations-Schutz
Informationen, die nicht direkt aus einer Quelle belegt werden können, werden im **Reasoning Layer** als spekulativ markiert. Nur belegte Fakten landen im **Technical Layer**.
