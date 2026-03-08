# 🎬 [SERVICES]: Media Stack Automation (Nixarr vs. Nixflix) (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir automatisieren deinen "Heimkino-Assistenten". Statt Stunden mit der Einrichtung von Programmen wie Sonarr oder Jellyfin zu verbringen, nutzen wir fertige Schablonen.
- **Problem:** Die manuelle Verknüpfung von 10 verschiedenen Medien-Apps ist mühsam und fehleranfällig.
- **Lösung:** Wir nutzen "Nixarr" für die Installation und "Nixflix" für die automatische Konfiguration.
- **Vorteil:** Einmal einschalten, und alle Apps sprechen automatisch miteinander.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Vergleich und Synergie von Nixarr und Nixflix.

### 📦 2.1 Nixarr (Installation)
- **Fokus:** Deklarative Installation der Services (Jellyfin, Sonarr, Radarr, SABnzbd).
- **Features:** Erstellt automatisch Verzeichnisse, Nutzer und Berechtigungen. Bietet einen VPN-Kill-Switch für Usenet/Torrents.
- **Status:** Stabil, Single Source of Truth für den Laufzeit-Zustand.

### ⚙️ 2.2 Nixflix (Konfiguration)
- **Fokus:** API-basierte Konfiguration ("Connective Tissue").
- **Features:** Setzt automatisch Indexer, Qualitätsprofile und Verknüpfungen via REST-API.
- **Status:** Alpha (v1.0 Milestone ausstehend). Ermöglicht echtes "Configuration as Code" für die App-internen Settings.

### 🔗 2.3 Ideale Kombination
```nix
# modules/media.nix
{ inputs, ... }: {
  imports = [ inputs.nixarr.nixosModules.default inputs.nixflix.nixosModules.default ];
  nixarr.enable = true; # Installiert Services
  nixflix.sonarr.indexers = [ ... ]; # Konfiguriert Services via API
}
```

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Divergenz-Prävention:** Ohne Nixflix driften die Einstellungen in der Weboberfläche vom Git-Stand ab. Nixflix erzwingt den Zustand bei jedem Rebuild.
- **Sicherheit:** Nixarr's VPN-Isolation (Network Namespaces) ist strukturell sicherer als reine Firewall-Regeln, da ein Leak physikalisch unmöglich ist.
- **Wiederverwendbarkeit:** Durch das Pinning auf spezifische Commits im Flake bleibt das System stabil, auch wenn die Community-Repos sich ändern.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-02 Homeserver mit Cloudflare sicher einrichten.md` (6.3.2026).
