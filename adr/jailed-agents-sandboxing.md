---
title: "AI Sandboxing Strategy: Jailed Agents via Bubblewrap"
category: "adr"
tags: [security, ai, agents, bubblewrap, nix-shell, stateless]
date: 2026-03-08
source: "architectural-legacy-v6.1"
status: "verified-substance-v6.1-definitive"
---

# 🤖 [ADR-INFO]: JAILED AI AGENTS (SANDBOX ARCHITECTURE)

Dieses Dokument definiert den Sicherheits-Standard für die Ausführung von KI-Agenten (wie Gemini-CLI, Claude-Code) auf dem mynixos Server.

---

## 🏗️ 1. USER LAYER: SICHERE KI (KISS)
KI-Agenten dürfen auf deinem Server arbeiten, aber sie können nichts kaputt machen.
- **Prinzip:** Sie leben in einer virtuellen Seifenblase (Sandbox).
- **Vorteil:** Du kannst neue Tools ausprobieren, ohne Angst um dein Betriebssystem haben zu müssen.

---

## 🛠️ 2. TECHNICAL LAYER: AVIATION-GRADE SPEZIFIKATION

### A. Die Bubblewrap (bwrap) Logik
Jeder Agent startet über einen spezialisierten Wrapper, der folgende Barrieren errichtet:
- **ReadOnly:** `/nix/store` und `/etc/static`. Der Agent kann keine Software deinstallieren oder System-Configs ändern.
- **No-Devices:** Kein Zugriff auf `/dev/dri` oder USB-Geräte, sofern nicht explizit deklariert.
- **Stateless Root:** `/` ist ein flüchtiges `tmpfs`. Alle Änderungen am Dateisystem werden beim Beenden gelöscht.

### B. Die Namespace-Isolation
```bash
# Beispielhafter Jailed-Start
bwrap --ro-bind /nix/store /nix/store \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --tmpfs /tmp \
      --unshare-all \
      --share-net \
      --proc /proc \
      --dev /dev \
      /bin/sh
```

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum Bubblewrap statt Docker?
Bubblewrap ist wesentlich leichtgewichtiger und benötigt keinen Hintergrund-Dienst (Daemon). Es nutzt native Linux-Kernel-Namespaces und ist somit perfekt für flüchtige CLI-Tools geeignet.

### Warum Stateless Agents?
KI-Agenten neigen dazu, temporäre Artefakte zu erzeugen. Durch die Sandbox-Isolation stellen wir sicher, dass diese "digitalen Krümel" die `/home` Partition nicht zumüllen. Nur explizit gemountete Projekt-Ordner sind persistent.

---

## 🧠 SRE-KONSEQUENZEN
- **Performance:** Fast Null Overhead im Vergleich zum nativen Prozess.
- **Forensik:** Im Fehlerfall lässt sich die Sandbox einfach "zerplatzen" (Kill-Signal), ohne dass Rückstände auf dem Host-System verbleiben.
