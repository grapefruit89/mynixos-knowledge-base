---
title: "Service: PostgreSQL Database (Aviation-Grade)"
category: "services"
tags: [database, postgresql, dendritic]
id: "NIXH-20-INF-002"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/20-infrastructure/postgresql.nix"]
---

# Service: PostgreSQL (Relational Database)

## 1. User Layer (KISS)
PostgreSQL ist das "Langzeitgedächtnis" deines Servers. Hier werden alle wichtigen Informationen deiner Programme sicher gespeichert. Das Modul sorgt dafür, dass die Datenbank extrem schnell arbeitet und sich automatisch selbst sichert.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Performance
* **Engine:** PostgreSQL v17 (via pkgs.postgresql_17).
* **Integrität:** Aktivierung von --data-checksums für Bitrot-Schutz.
* **Tuning:** shared_buffers = "512MB" und effective_io_concurrency = 200.

### SRE Hardening
* **Sandboxing:** Läuft in einer strict systemd-Sandbox.
* **OOM Protection:** OOMScoreAdjust = -900.

## 3. Reasoning Layer (History)

### [ADR-048] PostgreSQL 17 as Standard
PostgreSQL v17 wird als einzige relationale Datenbank für alle Dienste (n8n, Paperless, etc.) genutzt, um den Wartungsaufwand zu minimieren und die Backup-Strategie zu vereinheitlichen.
