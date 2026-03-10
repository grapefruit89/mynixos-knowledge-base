# [GUIDE]: Go-Native Productivity (Memos & Dagu)
# ID: [NUGGET-PROD-001] | Status: PROPOSED | Stand: 10.03.2026

## 1. Vision
Um die Produktivität auf dem MyNixOS-System zu maximieren, setzen wir auf hocheffiziente Go-Binaries, die sofort einsatzbereit sind und einen minimalen Ressourcen-Footprint haben.

## 2. Die Werkzeuge

### 📝 Memos: Dein persönlicher Gedanken-Hub
- **Zweck:** Schnelle Notizen, Micro-Blogging, Code-Schnipsel.
- **Nix-Pfad:** `pkgs.memos` / `services.memos.enable`.
- **Vorteil:** SQLite-basiert, Single-Binary, extrem schnell. Ersetzt schwere Wiki-Systeme für einfache Notizen.

### 🛡️ systemd & ntfy: Native Automatisierung
- **Zweck:** Wir verzichten auf externe Workflow-Engines wie Dagu oder n8n, wo immer möglich.
- **Standard:** Wir nutzen native NixOS `systemd.timers` für die Zeitsteuerung.
- **Veredelung:** Fehlerzustände werden via `ntfy` (ADR-025) direkt an den Admin gemeldet.

## 3. Integration
Diese Dienste leben im **Layer 50-knowledge** (Memos) und die Automatisierung erfolgt direkt über die systemnahen Layer via native NixOS-Konfiguration.

---
> [SOURCE]: https://github.com/awesome-selfhosted/awesome-selfhosted
