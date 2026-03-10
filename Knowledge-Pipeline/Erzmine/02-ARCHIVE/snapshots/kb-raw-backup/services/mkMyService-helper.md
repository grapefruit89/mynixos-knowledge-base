---
title: "Service Factory: mkMyService Operating Manual"
category: "services"
tags: [nixos, dendritic, framework, automation, hardening]
date: 2026-03-08
source: "architectural-legacy-v6.0"
status: "verified-substance-v6.0-definitive"
---

# 🛠️ SERVICE: THE mkMyService FACTORY

Dieses Dokument ist die Betriebsanleitung für die Erstellung neuer Service-Aspekte innerhalb der mynixos Distribution.

---

## 🏗️ 1. USER LAYER: SCHNELLEINSTIEG (KISS)
Um einen neuen Dienst (z.B. `radarr`) hinzuzufügen, musst du keine Firewall-Regeln oder Proxy-Routen schreiben. Nutze einfach den Helper:

```nix
{ config, ... }:
config.my.lib.mkMyService {
  name = "radarr";
  port = 7878;
  description = "Radarr Movie Management";
}
```
**Das Ergebnis:** Dein Dienst ist sofort unter `radarr.m7c5.de` erreichbar und sicher gehärtet.

---

## 🛠️ 2. TECHNICAL LAYER: AVIATION-GRADE AUTOMATION

### Was der Helper automatisch konfiguriert:
1. **Isolation:** Startet als `DynamicUser=true` mit eigenem `StateDirectory`.
2. **Hardening:** Aktiviert `ProtectSystem=strict`, `NoNewPrivileges` und `MemoryDenyWriteExecute`.
3. **Networking:** Beschränkt Address-Families auf `AF_INET`, `AF_INET6` und `AF_UNIX`.
4. **Proxy:** Erzeugt automatisch einen Caddy-VirtualHost mit `import sso_auth`.
5. **Permissions:** Fügt den Dienst der GID 169 (`media`) hinzu, für nahtlosen Zugriff auf Tier C Daten.

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum DynamicUser?
Klassische UIDs/GIDs sind fehleranfällig. `DynamicUser` weist bei jedem Start eine freie ID zu und verwaltet die Berechtigungen des `StateDirectory` automatisch. Dies eliminiert "Permission Denied" Fehler beim Setup.

### Warum GID 169 Integration?
Um das Problem der Zusammenarbeit zwischen verschiedenen Apps (Sonarr schreibt, Jellyfin liest) zu lösen. Durch die supplementary group `media` (169) haben alle "Arrr"-Apps eine gemeinsame Vertrauensbasis auf dem Dateisystem.

---

## 🧠 SRE-KONSEQUENZEN
- **Reproduzierbarkeit:** Jeder Dienst folgt dem identischen Sicherheits-Template.
- **Wartbarkeit:** Globale Härtungs-Updates (z.B. neue Kernel-Features) müssen nur an EINER Stelle (in `_lib.nix`) angepasst werden und wirken sofort für alle Dienste.
