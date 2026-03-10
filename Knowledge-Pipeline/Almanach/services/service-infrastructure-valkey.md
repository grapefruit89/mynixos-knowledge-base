---
title: "Service: Valkey Database (Aviation-Grade)"
category: "services"
tags: [database, cache, valkey, redis, dendritic]
id: "NIXH-20-INF-006"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/20-infrastructure/valkey.nix"]
---

# Service: Valkey (Key-Value Store)

## 1. User Layer (KISS)
Valkey ist das „Blitz-Gedächtnis“ deines Servers. Es speichert Daten, die extrem schnell abgerufen werden müssen (z.B. für Paperless oder n8n). Wir nutzen Valkey als modernen, offenen Ersatz für Redis. Das Modul sorgt für eine strikte Isolierung und begrenzt den Speicherverbrauch automatisch.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Performance
* **Engine:** Valkey (via pkgs.valkey) als Drop-in Ersatz für Redis.
* **Resource Management:** maxmemory = "512mb" mit allkeys-lru Policy.
* **UNIX Sockets:** Nutzung von /run/redis-valkey/redis.sock für performante lokale Kommunikation.

### SRE Hardening
* **Isolation:** ProtectSystem = "strict" und MemoryDenyWriteExecute = true.
* **OOM Protection:** OOMScoreAdjust = -500.

## 3. Reasoning Layer (History)

### [ADR-045] Migration to Valkey
Aufgrund von Lizenzänderungen bei Redis wurde Valkey als community-getriebener Standard für das Homelab-Projekt gewählt. Dies garantiert langfristige Wartbarkeit und volle Open-Source Konformität.
