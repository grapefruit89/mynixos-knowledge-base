# 📊 [SERVICES]: Dashboard Vergleich (Glance vs. Homepage vs. Homer) (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir brauchen eine Startseite für deinen Server. Wir haben drei Optionen: Ein "Profi-Cockpit" für dich (Glance/Homepage) und eine ganz einfache Seite mit nur drei Knöpfen für die Familie (Homer).
- **Problem:** Ein Dashboard mit 50 Diensten verwirrt die Familie.
- **Lösung:** Wir trennen die Dashboards. Du bekommst alle technischen Infos, die Familie nur die Links zu den Filmen und Hörbüchern.
- **Vorteil:** Übersichtlichkeit für alle.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Vergleich der Dashboard-Technologien in NixOS.

### 🏠 2.1 Homepage (Der Allrounder)
- **NixOS Integration:** Exzellent. Vollständige Konfiguration in Nix-Syntax möglich (`services.homepage-dashboard`).
- **Features:** Widgets für Container-Status, API-Integrationen (Sonarr/Radarr), schönes UI.
- **Nachteil:** Kein natives Multi-User. Lösung: Zwei separate Instanzen.

### ⚡ 2.2 Glance (Das Profi-Cockpit)
- **Technik:** Geschrieben in Go, extrem schnell (< 20MB RAM), statische Binary.
- **Features:** Starker Fokus auf Feeds (RSS, Reddit, YouTube) + Service-Links.
- **NixOS:** Modul vorhanden, aber Konfiguration aktuell noch primär via YAML.

### 🧊 2.3 Homer (Das Familien-Dashboard)
- **Technik:** Komplett statisch, extrem leichtgewichtig.
- **Features:** Reine Link-Liste, schlichtes Design.
- **Einsatz:** Ideal als "Einstiegsdroge" für die Familie hinter Cloudflare Access.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Trennung der Belange:** Admins brauchen Monitoring-Daten, User brauchen Funktionalität. 
- **Wartbarkeit:** Da alle drei Tools NixOS-Module haben, erfolgt die Konfiguration deklarativ im Flake. Keine manuelle Pflege von Docker-Volumes für die Dashboards nötig.
- **Sicherheit:** Dashboards werden nicht öffentlich exponiert, sondern sind ausschließlich über Cloudflare Access + PocketID erreichbar.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-02 Homeserver mit Cloudflare sicher einrichten.md` (6.3.2026).
