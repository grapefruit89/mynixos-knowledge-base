---
id: GUIDE-System-Auditing-NixoScope
title: System Auditing & Visualization with NixoScope
status: accepted
date: 2026-03-10
tags: [nixos, auditing, visualization, nixoscope, graphviz, dependencies]
---

# GUIDE: System Auditing with NixoScope

## 1. USER LAYER (KISS)
Wenn du viele kleine Module (Dendriten) hast, verliert man leicht den Überblick, wer wen importiert. **NixoScope** ist wie ein Röntgengerät für dein System. Es erstellt ein Bild (Diagramm), das alle Verbindungen zwischen deinen Nix-Dateien zeigt. So kannst du sofort sehen, ob dein System sauber strukturiert ist oder ob sich ein "Spaghetti-Code" aus Abhängigkeiten bildet.

## 2. TECHNICAL LAYER (Specification)

### Visualisierung der Modul-Abhängigkeiten
NixoScope analysiert die `imports = [ ... ]` Statements in deinen NixOS-Modulen.

#### Schnellanwendung (via Nix Run):
```bash
nix run github:Giom24/NixoScope -- . --output dependency_graph.dot
```

#### Umwandlung in ein Bild (erfordert Graphviz):
```bash
dot -Tpng dependency_graph.dot -o system_map.png
```

### Aviation-Grade Audit Rules:
Mit NixoScope prüfen wir folgende Regeln:
1.  **Layer-Compliance:** Ein Modul in `00-core` darf niemals etwas aus `40-media` oder `80-monitoring` importieren (Zirkelbezug-Gefahr!).
2.  **Dendritische Reinheit:** Ein Dienst (z.B. Jellyfin) sollte idealerweise keine Abhängigkeiten zu anderen Diensten haben, sondern nur zum Core oder zu Libraries.
3.  **Visualisierung des "Chaos":** Wenn das Diagramm zu viele Kreuzungen hat, ist es Zeit für ein Refactoring in eine "Library" oder ein "Common"-Modul.

## 3. REASONING LAYER (ADR)

### Warum NixoScope statt nix-tree?
- **nix-tree** zeigt, welche Pakete auf der Festplatte liegen (Disk Usage).
- **NixoScope** zeigt, wie deine *Konfiguration* gedacht ist (Architektur). Es ist ein Werkzeug für den SRE, um die Logik des Systems zu verstehen, nicht nur den Speicherplatz.

### Warum Graphviz (DOT)?
Das DOT-Format ist ein Industriestandard. Die Diagramme können direkt in die Dokumentation (oder in diese Knowledge Base) eingebunden werden, um den Ist-Zustand der Architektur zu beweisen.

---
> [ARCHITECT-NOTE]: Basierend auf der Wunschliste (Giomf/NixoScope) und SRE-Auditing-Mandat.
