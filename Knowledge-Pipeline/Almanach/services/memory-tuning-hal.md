# ⚡ [SERVICES]: Memory Tuning & Tier-0 (zram) (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir sorgen dafür, dass dein System nie "ins Stottern" kommt, indem wir den Arbeitsspeicher (RAM) clever nutzen.
- **Problem:** Die Festplatte (NVMe) ist zwar schnell, aber der Arbeitsspeicher ist noch viel schneller. Wenn der RAM voll ist, fängt das System an, auf die Festplatte zu schreiben, was diese abnutzt und das System verlangsamt.
- **Lösung:** Wir nutzen "zram" – eine Art Turbo-Kompression für den Arbeitsspeicher. Daten werden im RAM komprimiert, statt sie auf die Festplatte zu schieben. Außerdem lagern wir temporäre Dateien (wie Vorschaubilder von Jellyfin) komplett in den RAM (Tier 0).
- **Vorteil:** Das System reagiert blitzschnell, und die Festplatte wird geschont.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation des Memory-Managements (`00-core/hal-memory.nix`).

### 🚀 2.1 zram & Swappiness
- **zramSwap:** Nutzt `zstd` Kompression. Priorität 200 (höher als Disk-Swap).
- **vm.swappiness = 180:** Aggressives Paging in den zram-Swap statt auf die Disk.
- **Dynamic Sizing:** Automatische Anpassung der zram-Größe basierend auf dem verfügbaren `ramGB`.

### 📂 2.2 Tier-0 RAM Cache (tmpfs)
Flüchtige Caches werden direkt in den RAM gemountet (`/run/nixhome-cache/`):
- `thumbnails`: 256MB für Jellyfin.
- `arr-icons`: 64MB für Sonarr/Radarr Icons.
- `caddy-tmp`: 128MB für temporäre Caddy-Dateien.

### 💾 2.3 Write-Behind Tuning
Optimierung der `vm.dirty_*` Werte, um Schreibvorgänge auf die NVMe zu bündeln und die Latenz zu verringern.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **NVMe Lebensdauer:** Durch zram und RAM-Caches werden unnötige Schreibzyklen auf die SSD/NVMe massiv reduziert.
- **Performance:** RAM-Zugriffe sind um Größenordnungen schneller als Disk-Zugriffe. Tier 0 sorgt dafür, dass die Benutzeroberfläche (z.B. Jellyfin) extrem reaktionsschnell bleibt.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-03 Prompt-Übernahme anfragen.md` (Conversational SRE Review 3.3.2026).
