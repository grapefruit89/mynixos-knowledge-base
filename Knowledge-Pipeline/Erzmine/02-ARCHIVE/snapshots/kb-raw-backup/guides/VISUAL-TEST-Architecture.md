---
title: 📐 Architektur-Visualisierung (Mermaid Test)
category: architecture/core
status: [TESTING]
capabilities: [diagram-rendering, architecture-map]
---

# 📐 mynixos: Die visuelle Architektur

Dieses Dokument dient als Test für den automatischen Mermaid-Renderer. Es zeigt den Datenfluss durch deinen Tower.

```mermaid
graph TD
    User((👤 User)) -->|HTTPS| Caddy[🛡️ Caddy Gateway]
    Caddy -->|Auth Check| PocketID{🔐 PocketID}
    
    subgraph "Dendritic Services"
        PocketID -->|OK| Media[🎬 Media Stack]
        PocketID -->|OK| Knowledge[📚 Knowledge Layer]
        PocketID -->|OK| Auto[🤖 Automation]
    end
    
    subgraph "Storage Tiers"
        Media -->|Read/Write| TierC[(💾 Tier C: ext4 Pool)]
        Knowledge -->|State| TierA[(🚀 Tier A: ZFS NVMe)]
        Auto -->|State| TierA
    end
    
    subgraph "Safety Net"
        TierA -->|Daily Sync| R2[☁️ Cloudflare R2]
        TierA -->|Backup| Restic[🛡️ Restic Vault]
    end
```

## 🚀 SRE-Anwendung
Wenn du dieses File in GitHub öffnest, sollte das Diagramm oben als professionelle Grafik erscheinen. Dies ist der neue Standard für alle ADRs in mynixos.
