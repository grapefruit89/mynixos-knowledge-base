---
title: "Python High CPU Load Resolution"
category: "learnings"
tags: [troubleshooting, python, cpu, unraid]
date: 2026-03-08
source: "raw/_duplikate/Gemini-Python-Prozess verursacht hohe Systemlast.md"
status: "verified-substance"
---

# 🧠 LEARNING: SYSTEM LAST DURCH PYTHON PROZESSE

Lösung für CPU-Auslastung (98.6%) durch verwaiste `pt_main_thread` Instanzen.

## 🔍 DIAGNOSE
```bash
pgrep -f python
top -c # Sortierung nach %CPU
```

## 🛠️ LÖSUNG (GEZIELT)
```bash
# Harter Abbruch aller Python-Instanzen
pkill -9 -f python
```

> [ARCHITECT-NOTE]: Unter Unraid/NixOS sollten solche Prozesse idealerweise in einem **Docker-Container mit CPU-Quota** (`cpus: 0.5`) laufen, um ein Einfrieren des Host-Systems bei Fehlfunktionen zu verhindern.
