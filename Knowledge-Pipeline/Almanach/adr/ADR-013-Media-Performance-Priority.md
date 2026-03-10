---
title: ADR-013: Resource Priority & Throttling
status: [ACCEPTED]
category: architecture/decision
---

# 🏛️ ADR-013: Ressourcen-Hierarchie (Revision v2.0)

## Entscheidung
Wir implementieren eine "Zwei-Klassen-Gesellschaft" auf dem Tower:
1. **First Class (A/V):** Jellyfin, Navidrome erhalten Nice -10 und GPU-BindPaths. ✅
2. **Second Class (Downloader):** SABnzbd erhält CPUQuota=50%, Nice 19 und IOSchedulingClass=idle. ✅

## Begründung
Garantiert ruckelfreies Streaming, während im Hintergrund Terabytes entpackt werden.