# 🏗️ [ADR]: Hardware Abstraction Layer (HAL) Integration (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir bauen eine "Universal-Steckdose" für deine Hardware. Egal ob dein System auf einem Intel-PC, einem AMD-Server oder einem Raspberry Pi (ARM) läuft – die Programme (wie Jellyfin) merken den Unterschied nicht mehr.
- **Problem:** Momentan stehen Intel-Treiber direkt in den App-Konfigurationen. Wenn du die Hardware wechselst, bricht alles zusammen.
- **Lösung:** Eine Zwischenschicht (HAL). Das Programm fragt nur noch: "Gib mir Grafik-Beschleunigung", und der HAL liefert automatisch den richtigen Treiber für die aktuelle Hardware.
- **Vorteil:** Du kannst deine Konfiguration ohne Änderungen auf neue Hardware umziehen.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation des HAL-Moduls (`00-core/hal.nix`).

### 🛠️ 2.1 Kernkomponenten
- **Platform Detection:** Automatische Erkennung via `pkgs.stdenv.hostPlatform` (x86_64 vs. Aarch64).
- **Capability Matrix:** Mapping von Hardware-Typen (Intel/AMD/ARM-Mali) zu Paketen, Kernel-Modulen und Device-Nodes.
- **Auto-Detect & Override:** Standardmäßige Erkennung basierend auf `cpuType`, mit manueller Override-Option für komplexe Setups.

### 📜 2.2 Implementierungs-Standard
- **Public API:** Module greifen ausschließlich auf `config.my.hal.capabilities` zu (z.B. `hal.envVars`, `hal.packages`).
- **Assertions:** Harte Build-Abbrüche bei Inkompatibilitäten (z.B. Intel-QSV auf ARM).
- **Service-Integration:** Dienste wie Jellyfin nutzen `DeviceAllow` und `environment` Variablen direkt vom HAL.

```nix
# Beispiel: Jellyfin nutzt HAL
systemd.services.jellyfin.environment = config.my.hal.capabilities.gpu.envVars;
```

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Blast Radius Minimierung:** Fehlkonfigurationen führen nicht mehr zu Kernel-Panics beim Booten, sondern werden bereits zur Evaluierungszeit durch Nix-Assertions abgefangen.
- **Wartbarkeit:** Treiber-Updates müssen nur an einer Stelle (im HAL) gepflegt werden, statt in 10 verschiedenen Service-Modulen.
- **Zukunftssicherheit:** Bereitet das System auf eine hybride Architektur (Intel-Hauptserver + ARM-Edge-Nodes) vor.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-03 Prompt-Übernahme anfragen.md` (Conversational SRE Review 3.3.2026).
