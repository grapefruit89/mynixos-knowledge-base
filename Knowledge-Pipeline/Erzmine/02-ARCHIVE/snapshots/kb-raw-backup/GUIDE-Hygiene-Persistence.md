---
title: Hygiene & Persistence (Impermanence Standard)
category: architecture/hygiene
capabilities: [root-in-ram, persistence-mapping, anti-forensics]
sources: [https://github.com/nix-community/impermanence]
---

# 🧹 Hygiene & Persistence: Das Impermanence Prinzip

In einem Aviation-Grade System ist das Root-Dateisystem (`/`) flüchtig. Alles, was nicht explizit gespeichert werden soll, wird bei jedem Reboot gelöscht.

## 🚀 Warum Impermanence?
- **Anti-System-Rot:** Verhindert das Ansammeln von Datenmüll.
- **Deklarative Sicherheit:** Alles, was persistiert werden soll, MUSS im Nix-Code stehen.

## 📁 Persistence Mapping
Wir nutzen den Ordner `/persist/` (auf ZFS oder SSD), um wichtige Daten zu halten.
- `/persist/var/lib/couchdb`
- `/persist/home/grapefruit89`

## 🧩 Modul-Integration
Jeder Dendrit (Dienst) deklariert seine eigenen Persistenz-Pfade. 
