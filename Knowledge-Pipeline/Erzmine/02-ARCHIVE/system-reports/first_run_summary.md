---
title: "First Run Summary: The mynixos Evolution Genesis"
category: "learnings"
tags: [summary, architecture, genesis, nixos, storage, identity]
date: 2026-03-08
source: "session-0803-genesis"
status: "verified-substance-definitive"
---

# 🚀 FIRST RUN SUMMARY: DIE GEBURT DER MYNIXOS DISTRIBUTION

Dieses Dokument fasst die Ergebnisse der ersten großen Knowledge-Engineering-Session zusammen. Wir haben den Grundstein für den Übergang von einer Legacy-Struktur zu einer modernen, dendritischen NixOS-Distribution gelegt.

---

## 🏗️ I. KNOWLEDGE ARCHITECTURE (DIE PIPELINE)

### 1. Das Manifest (GEMINI.md)
Wir haben ein unumstößliches Gesetz für jede KI-Instanz geschaffen:
- **Anti-Halluzinations-Gesetz:** Physische Beweispflicht (`ls -l`) vor jeder Erfolgsmeldung.
- **Wissens-Erhaltungs-Gebot:** Kein Löschen von technischen Details; Dokumente folgen dem Drei-Layer-Standard (KISS, Technical, Reasoning).
- **Verzeichnis-Hygiene:** `/root/` ist verboten; `/home/Knowledge-Pipeline/` ist das Zentrum.

### 2. Die RAG-Bibliothek
- **Status:** Über 20 Dokumente aus Roh-Chats wurden refaktoriert, mit YAML-Headern versehen und in `adr/`, `services/` und `learnings/` einsortiert.
- **Master-Index:** Ein zentrales Gehirn (`00_MASTER_INDEX.md`) verlinkt alle Themen.

---

## 🛰️ II. SYSTEM ARCHITECTURE (DIE DISTRIBUTION)

### 1. Das Dendritic-Fundament (den Framework)
- **Vision:** Ein "Opinionated NixOS Starter" für Self-Hoster.
- **Abstraktion:** Nutzer interagieren nur mit `USER_CONFIG.nix` und `secrets.sops.yaml`.
- **Engine:** `den.lib.make` mit automatischer Modul-Erkennung via `import-tree`.

### 2. Das ABC Storage System (Precision Tiering)
- **Tier A (Hot):** NVMe + ZFS (Bitrot-Schutz für OS/State).
- **Tier B (Warm):** SSD + EXT4 (Metadaten & Download-Schleuse).
- **Tier C (Cold):** HDD + EXT4 (Der "Friedhof" für Medien, keine Parität).
- **Mover-Logik:** Hysterese-gesteuert (90% -> 80%), opportunistisches Verschieben bei HDD-Aktivität, Nacht-Scan (03:00) ohne Spin-up.

### 3. Souveräne Identität (Zero-Touch Boot)
- **Master-Stick:** Physisch exklusiver Token mit LUKS-verschlüsselter Ignition-Zelle.
- **Network DNA:** Passiver MAC-Fingerprint der Umgebung als Standort-Anker.
- **Push-Unlock:** Aktive Bestätigung via Smartphone statt manueller Passwörter.

---

## 🛡️ III. SECURITY & PROXY (M1 ABRAMS EDITION)

### 1. Caddy Gateway
- **Features:** mTLS für Dashboards, Pocket-ID SSO für Public-Access, HTTP/3 & ECH für Privatsphäre.
- **Automation:** OliveTin als Interface für die Zertifikatserstellung und das SOPS-Management.

### 2. Jailed Agents
- **Konzept:** KI-Agenten laufen in einer flüchtigen **Bubblewrap** Sandbox ohne Host-Zugriff.

---

## 📜 IV. REASONING LAYER (WARUM DIESER WEG?)
Wir haben uns für diesen radikalen Weg der Dokumentation entschieden, um den "Mover-Effekt" (Wissensverlust) zu verhindern. Jede Entscheidung (z.B. EXT4 für Tier B/C zur einfacheren Recovery) wurde gegen Enterprise-Lösungen (ZFS-only) abgewogen, um die Praxistauglichkeit für den Heimserver-Alltag zu garantieren.

---

## ✅ NÄCHSTER MEILENSTEIN
Vollständige Implementierung der `modules/services/_lib.nix` Factory und Migration des Media-Stacks (Arrr-Apps) in das Dendritic-Schema.
