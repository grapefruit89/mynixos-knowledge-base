---
title: Architecture-NIXHOME-Dendritic-Structure (Aviation-Grade Nugget)
category: architecture/legacy-import
capabilities: [archived-knowledge, traceability-fix]
sources: [https://github.com/mightyiam/best-of-nix]
---

# Architecture: NIXHOME Dendritic Structure

## 1. User Layer (KISS)
Dieses Dokument beschreibt das "Skelett" deines NixOS-Servers – die Ordnerstruktur. Wir folgen dem Prinzip **"Flat by Default, Deep by Necessity"**. Das bedeutet: So wenige Ordner wie möglich, aber so viele wie nötig, um die Übersicht zu behalten. Jeder Dienst (wie Jellyfin oder Vaultwarden) bekommt genau eine eigene Datei, in der alles steht, was er zum Laufen braucht. Das macht das Kopieren, Teilen und Reparieren deines Systems extrem einfach.

## 2. Technical Layer (Aviation-Grade)

### Repository-Layout (Final V6.x)
```text
mynixos/
├── flake.nix                # Zentrale Definition (Inputs, Host-Aktivierung)
├── flake.lock               # Pinning aller Versionen (Reproduzierbarkeit)
├── .sops.yaml               # Secret-Verschlüsselungs-Regeln
├── secrets.sops.yaml        # Verschlüsselte Passwörter
│
├── hosts/
│   └── q958/
│       ├── default.nix      # Welche Layer/Module sind aktiv?
│       ├── hardware.nix     # Auto-generierte Hardware-Config
│       └── disko.nix        # Deklarative Partitionierung
│
└── modules/                 # "Flat by Default" Layer
    ├── 00-core/             # OS-Fundament (SSH, Users, Network, Firewall)
    ├── 20-server/           # Erreichbarkeit (Caddy, DNS, DBs, Pocket-ID)
    ├── 30-services/         # Täglich genutzte Apps (n8n, HA, Vaultwarden)
    ├── 40-media/            # Audio/Video (Jellyfin, ARR-Stack)
    ├── 50-knowledge/        # Wissen (Paperless, Monica, RSS)
    ├── 80-monitoring/       # Beobachtung (Netdata, Uptime Kuma)
    └── 90-policy/           # Enforcement (Assertions, Struktur-Checks)
```

### Modul-Design (Single-File-Principle)
Jedes Modul in `modules/` ist in sich geschlossen und enthält:
1.  **NMS-Meta-Header:** Für Obsidian und KI-Extraktion.
2.  **Options:** Was kann in der `hosts/`-Config eingestellt werden?
3.  **Config:** Die eigentliche NixOS-Konfiguration inklusive systemd-Hardening.
4.  **Ingress:** Die Caddy-Reverse-Proxy Konfiguration direkt in der Datei.

## 3. Reasoning Layer (History)

### [ADR-012] Flat by Default vs. Tief verschachtelte Strukturen
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Tief verschachtelte Ordnerstrukturen erschweren die Navigation und führen oft zu Zirkelabhängigkeiten beim Importieren.
*   **Entscheidung:** Nutzung einer flachen Layer-Struktur. Ein neuer Ordner wird erst angelegt, wenn drei oder mehr zusammengehörige Dateien entstehen (z.B. der ARR-Stack in `40-media/`).
*   **Vorteile:** Einfachere Import-Hubs (`default.nix` pro Layer).

### [ADR-013] Denix/Dendritic Pattern Integration
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Trennung von NixOS und Home-Manager Konfiguration führt oft zu redundanten Dateien.
*   **Entscheidung:** Nutzung des Dendritic-Musters (inspiriert durch Denix). Alles, was zu einem Dienst gehört, bleibt in einer Datei.
*   **Konsequenzen:** Erfordert eine saubere Nutzung von `lib.mkIf` und `lib.mkMerge` innerhalb der Module.

---
**Sources:**
*   `/home/Knowledge-Pipeline/raw/_duplikate/NIXHOME_ARCHITECTURE.md`
*   `/home/Knowledge-Pipeline/raw/_duplikate/Gemini-Software Konzepte für NixHome MetaBibliothek.md`
*   `https://github.com/grapefruit89/mynixos/`
