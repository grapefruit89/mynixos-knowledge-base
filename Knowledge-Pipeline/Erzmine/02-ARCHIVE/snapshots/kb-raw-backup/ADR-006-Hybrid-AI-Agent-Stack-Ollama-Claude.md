---
id: ADR-006
title: Hybrid AI Agent Stack (Ollama & Claude Code)
status: accepted
date: 2026-03-10
tags: [ai, ollama, claude, hybrid, gpu, vulkan, agents]
---

# ADR-006: Hybrid AI Agent Stack (Ollama & Claude Code)

## 1. USER LAYER (KISS)
Wir nutzen künstliche Intelligenz direkt auf deinem Server, um Aufgaben zu automatisieren und Code zu schreiben. Das System ist "Hybrid": Wir nutzen **Ollama** für lokale Modelle (die keine Cloud brauchen und deine Privatsphäre schützen) und verknüpfen sie mit **Claude Code** für komplexere Programmier-Aufgaben. Durch die Nutzung deiner Intel-Grafikkarte (GPU) reagiert die KI blitzschnell, ohne deinen Prozessor zu belasten.

## 2. TECHNICAL LAYER (Specification)

### Die Agent-Orchestrierung (`kimi-claude`)
Ein spezialisierter Shell-Wrapper (`kimi-claude`) koordiniert den Start der lokalen Modelle und der Agenten-Umgebung.

#### Implementierungs-Details:
- **Lokal-Modell:** `ollama run kimi-k2.5:cloud` (Optimiertes Modell für lokale Aufgaben).
- **Agenten-CLI:** `claude-code` (via npx/Node.js 22) für die autonome Code-Manipulation.
- **Hardware-Abstraktion:** NixOS wählt dynamisch das Paket `ollama-vulkan`, wenn eine Intel-GPU erkannt wurde (`config.my.configs.hardware.intelGpu`), um VA-API/Vulkan-Beschleunigung zu nutzen.

#### Systemd Hardening:
Der Ollama-Hintergrunddienst ist durch Sandboxing isoliert:
- `ProtectSystem=strict`
- `DeviceAllow=[ "/dev/dri/renderD128 rw" ]` (Nur Zugriff auf die GPU, nicht auf andere Hardware).

### Integration mit n8n
Die AI-Agenten dienen als "Tools" für den Automatisierungs-Kern (n8n), um Dokumente zu analysieren, E-Mails zu verfassen oder System-Audits durchzuführen.

## 3. REASONING LAYER (ADR)

### Warum Hybrid (Ollama + Claude)?
- **Souveränität:** Einfache Aufgaben (z.B. Text-Klassifizierung) bleiben lokal auf Ollama. Das spart Kosten und schützt Daten.
- **Leistung:** Komplexe Refaktorisierungen nutzen die Cloud-Power von Claude, während der Kontext (deine lokalen Dateien) durch den Agenten kontrolliert wird.

### Warum Vulkan/VPL-GPU-Beschleunigung?
Der Fujitsu Q958 (i3-9100) hat eine potente iGPU (UHD 630). Durch die Nutzung von Vulkan (`ollama-vulkan`) wird die CPU entlastet, was die System-Stabilität bei parallelen Aufgaben (z.B. Media-Streaming + AI-Chat) massiv verbessert.

### Alternativen (Verworfen):
- **Pure Cloud-AI:** Zu teuer und abhängig von der Internetverbindung.
- **Pure Local-AI:** Bei komplexen Programmieraufgaben (Nix-Flakes) oft noch zu ungenau.

---
> [ARCHITECT-NOTE]: Extrahiert aus mynixos/30-automation/service-app-ai-agents.nix (v2026.03.02)
