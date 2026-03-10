---
title: ADR-003: Ejected Services & Efficiency Cleanup
status: [ACCEPTED]
category: architecture/decision
capabilities: [resource-efficiency, binary-mandate, no-legacy]
sources: [User Rauswurf-Liste, GEMINI.md V2026]
---

# 🏛️ ADR-003: Exkommunikation ineffizienter Dienste

## Kontext
Zur Wahrung des Binary-Effizienz-Mandats und der System-Purity müssen Dienste entfernt werden, die dem Aviation-Grade Standard widersprechen.

## Entscheidung
Folgende Dienste sind ab sofort für die mynixos Distribution VERBOTEN:

| Dienst | Grund für Ejection |
|---|---|
| Traefik | Caddy ist SSoT-Proxy |
| Redis | Valkey (Go-Fork) ist SSoT-Cache |
| Speedtest-tracker | PHP-Stack (Verstoß Binary-Mandat) |
| Agent-Zero | Python-Stack / kein natives Modul |
| Readarr-fork | Instabil / kein offizielles Modul |
| Audiobookrequest | In Audiobookshelf integriert |

## Konsequenz
Diese Dienste werden in keinen Indizes mehr geführt. Dokumentation wird nach `/raw/_duplikate/` verschoben.
