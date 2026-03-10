---
title: "The Den Framework: Architectural Foundation"
category: "adr"
tags: [nixos, den, dendritic, architecture, framework, flake-parts]
date: 2026-03-08
source: "https://github.com/vic/den"
status: "live-validated-v6.6-definitive"
---

# 🏗️ [ADR-INFO]: DEN & THE DENDRITIC PATTERN (DEFINITIVE EDITION)

Dieses Dokument definiert das Framework-Fundament der mynixos Distribution. Es basiert auf dem Dendritic-Pattern, das radikale Modularität durch die Umkehrung der Import-Logik erreicht.

---

## 🏗️ 1. USER LAYER: MODULARITÄT OHNE SCHMERZ (KISS)
In herkömmlichen Nix-Systemen musst du jede neue Datei manuell in einer Liste eintragen. In unserem System ist das vorbei:
- **Prinzip:** "Jede Datei ist ein Modul".
- **Aktion:** Erstelle eine `.nix` Datei im Ordner `features/` – sie wird sofort vom System erkannt und geladen.
- **Vorteil:** Du kannst dich auf das Konfigurieren konzentrieren, anstatt dich um Import-Strukturen zu kümmern.

---

## 🛠️ 2. TECHNICAL LAYER: AVIATION-GRADE SPEZIFIKATION

### A. Die Engine: `flake-parts` & `den`
Wir nutzen `flake-parts` als Basis und das `den` Framework zur Kontext-Steuerung.
- **Auto-Import:** Integration von `import-tree`, um das gesamte Verzeichnis `./modules` rekursiv zu evaluieren.
- **Deferred Modules:** Wir nutzen den Typ `deferredModule` aus Nixpkgs für Sub-Module, um Konflikte beim Mergen von Attributen (z.B. Firewall-Regeln) zu minimieren.

### B. Das "Aspect" Modell
Ein Aspekt definiert eine funktionale Einheit (z.B. `gaming` oder `media-server`), die klassenübergreifend agiert:
```nix
{ den, ... }: den.aspect {
  # Konfiguration für NixOS
  nixos = { ... };
  # Konfiguration für Home-Manager (User-Ebene)
  homeManager = { ... };
}
```

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum der Verzicht auf `specialArgs`?
In einer echten dendritischen Architektur haben alle Module Zugriff auf den globalen `config` Scope. Dies eliminiert die Notwendigkeit, Variablen mühsam durch Tunnel (`specialArgs`) zu reichen, was die Fehleranfälligkeit bei großen Setups massiv reduziert.

### Warum Feature-Oriented statt Class-Oriented?
Früher waren NixOS und Home-Manager-Configs getrennt. Das führte dazu, dass Wissen über einen Dienst (z.B. Caddy-Config vs. User-Zertifikate) über verschiedene Ordner verstreut war. Mit dem **Aspect-Modell** lebt alles, was zu einem Thema gehört, in EINER Datei.

---

## 🧠 SRE-KONSEQUENZEN
- **Skalierbarkeit:** Das System bleibt auch bei >500 Modulen wartbar.
- **Beweis:** Physische Trennung von Implementation (Aspekt) und Einsatzort (Kontext).
