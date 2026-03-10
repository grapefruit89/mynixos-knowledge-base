# 🏗️ [ADR]: Dendritic vs. Denix Architektur-Pattern (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir organisieren deine Einstellungen nach "Themen" (Features) statt nach "Servern". Wenn du sagst "ich will Jellyfin", dann ist alles, was dazu gehört, in einer einzigen Datei.
- **Problem:** In normalen Systemen sind die Einstellungen für ein Programm oft über viele Dateien verstreut.
- **Lösung:** Wir nutzen das "Dendritic Pattern". Jede Datei ist ein abgeschlossenes Modul für ein bestimmtes Thema.
- **Vorteil:** Du kannst einzelne Themen (wie Jellyfin oder Hardening) einfach kopieren und auf anderen Servern wiederverwenden.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation der Modul-Struktur.

### 🌳 2.1 Dendritic (Das Pattern)
- **Konzept:** Jede Nix-Datei repräsentiert ein Feature. Keine komplexen `specialArgs` oder tief verschachtelten Import-Bäume.
- **Regel:** "Flat by default, deep by necessity". Neue Ordner entstehen erst ab 3 zusammengehörigen Dateien.
- **Struktur:**
  - `modules/core/`: Alles was auf jedem Server läuft (SSH, Users, Hardening).
  - `modules/media/`: Der Media-Stack.
  - `modules/services/`: Einzelne Apps.

### 🧪 2.2 Denix (Das Framework)
- **Funktion:** Eine Library, die das Dendritic-Pattern automatisiert. Trennt NixOS-, Home-Manager- und Darwin-Konfigurationen, die in derselben Datei geschrieben werden.
- **Einsatz:** Ideal für Multi-Host-Setups (Laptop + Server) und zur Erstellung von "Distribution-Templates".

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Portabilität:** Das Ziel ist ein "Opinionated NixOS Starter". Nutzer sollen das Repo klonen, Hardware und Username in einer zentralen Datei anpassen, und der Rest (die Dendritic-Module) funktioniert sofort.
- **Wartbarkeit:** Durch die thematische Trennung (Features) sinkt die kognitive Last beim Debugging. Man weiß sofort, in welcher Datei ein Problem zu suchen ist.
- **Zukunftssicherheit:** Denix bietet den Weg von einer reinen Server-Konfiguration zu einem umfassenden Dotfile-Management für alle persönlichen Geräte.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-02 Homeserver mit Cloudflare sicher einrichten.md` (6.3.2026).
