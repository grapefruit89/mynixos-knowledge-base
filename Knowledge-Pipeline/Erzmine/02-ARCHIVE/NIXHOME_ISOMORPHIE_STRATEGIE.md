# 🛰️ NIXHOME ISOMORPHIE-STRATEGIE
## Code ↔ Docs ↔ Obsidian — Perfekte strukturelle Spiegelung

Stand: 2026-03-02

---

# DAS KERNPROBLEM

Du hast drei Welten die auseinanderdriften:

```
/etc/nixos/          → Nix-Code      (Wahrheit: Was das System TUT)
650 Chaos-Docs/      → Markdown      (Wahrheit: Was du WEISST)
Obsidian Vault/      → Knowledge DB  (Wahrheit: Was du FINDEST)
```

Wenn eine Wahrheit sich ändert, stimmen die anderen nicht mehr.
**Lösung:** Eine SSOT — der NMS-Header. Er lebt primär in der `.nix`-Datei
und wird von dort in alle anderen Welten gespiegelt.

```
.nix Header  ──→  .md Header (automatisch gespiegelt)
     │                  │
     └────→  Obsidian Frontmatter (identisch)
```

---

# TEIL 1: DER FINALE NMS-HEADER STANDARD

## Feldkatalog (kanonisch, v2.3)

Jedes Feld hat genau einen Zweck. Kein Feld ist doppelt, keins fehlt.

```yaml
# ═══════════════════════════════════════════════════
# BLOCK 1: IDENTITÄT — Wer bin ich?
# ═══════════════════════════════════════════════════
id: "NIXH-40-MEDIA-001"
# Schema: NIXH-{LAYER}-{KATEGORIE}-{NUMMER}
# LAYER:     00|20|30|40|50|80|90
# KATEGORIE: CORE|SERVER|SVC|MEDIA|KNOW|MON|POL
# NUMMER:    001..999

title: "Jellyfin Media Server"
description: "Hardware-accelerated media streaming with declarative QSV/iHD transcoding"
homepage: "https://jellyfin.org/"
nms_version: "2.3"
layer: 40

# ═══════════════════════════════════════════════════
# BLOCK 2: KLASSIFIKATION — Wozu gehöre ich?
# (Nixpkgs-kompatibel — direkt aus nixpkgs Pfad-Logik)
# ═══════════════════════════════════════════════════
nixpkgs:
  category: "servers/media"
  # Kategorien: system/boot | system/networking | security/hardening
  #             servers/proxy | servers/database | servers/media
  #             services/automation | services/web-apps | services/misc
  #             applications/media | tools/admin | tools/monitoring
  module_path: "nixos/modules/services/misc/jellyfin.nix"

# ═══════════════════════════════════════════════════
# BLOCK 3: CAPABILITIES — Was kann ich?
# (Durchsuchbar in Obsidian Dataview)
# ═══════════════════════════════════════════════════
capabilities:
  hardware:
    - "gpu/intel-qsv"        # QSV Hardware-Transcoding
    - "gpu/opencl"           # OpenCL Tonemapping
  sandboxing:
    - "systemd/strict"       # ProtectSystem=strict
    - "systemd/no-new-privs" # NoNewPrivileges
  ingress:
    - "caddy/reverse-proxy"  # Hinter Caddy
    - "tailscale/trusted"    # Tailscale direkt (kein SSO nötig)
  storage:
    - "mergerfs/tier-c"      # Bibliothek auf HDD-Pool
    - "mergerfs/cache-b"     # Transcode-Cache auf SSD

# ═══════════════════════════════════════════════════
# BLOCK 4: ARCHITEKTUR — Von wem hänge ich ab?
# (Für automatischen Dependency-Graph)
# ═══════════════════════════════════════════════════
architecture:
  upstream:                  # Ich brauche diese Module
    - "NIXH-00-CORE-001"     # configs.nix
    - "NIXH-00-CORE-002"     # ports.nix
    - "NIXH-20-SERVER-001"   # caddy.nix
  downstream:                # Diese Module brauchen mich
    - "NIXH-40-MEDIA-002"    # jellyseerr.nix
  status: "audited"          # draft | audited | deprecated

# ═══════════════════════════════════════════════════
# BLOCK 5: RESSOURCEN — Was verbrauche ich?
# (Aus ports.nix + systemd-Limits)
# ═══════════════════════════════════════════════════
resources:
  port: 20096
  state_path: "/data/state/jellyfin"
  ram_limit: "4G"
  cpu_weight: 80
  oom_score: 200

# ═══════════════════════════════════════════════════
# BLOCK 6: TRACEABILITY — Wo lebe ich sonst noch?
# (Die Brücke zwischen den drei Welten)
# ═══════════════════════════════════════════════════
ref:
  code: "40-media/jellyfin.nix"          # Pfad im Repo
  doc:  "40-media/jellyfin.md"           # Pfad in Obsidian
  port_registry: "00-core/ports.nix#L42" # Wo der Port definiert ist

# ═══════════════════════════════════════════════════
# BLOCK 7: AUDIT — Wie gut bin ich dokumentiert?
# ═══════════════════════════════════════════════════
audit:
  last_reviewed: "2026-03-02"
  complexity: 3              # 1=trivial 2=einfach 3=mittel 4=komplex 5=kritisch
  doc_status: "enriched"     # stub | draft | enriched | complete
  open_issues: []
```

---

## In der .nix-Datei (als Kommentarblock)

```nix
/**
 * ---
 * id: "NIXH-40-MEDIA-001"
 * title: "Jellyfin Media Server"
 * description: "Hardware-accelerated media streaming with declarative QSV/iHD transcoding"
 * layer: 40
 * nixpkgs.category: "servers/media"
 * capabilities.hardware: ["gpu/intel-qsv", "gpu/opencl"]
 * capabilities.ingress: ["caddy/reverse-proxy", "tailscale/trusted"]
 * architecture.upstream: ["NIXH-00-CORE-001", "NIXH-00-CORE-002", "NIXH-20-SERVER-001"]
 * resources.port: 20096
 * ref.doc: "40-media/jellyfin.md"
 * audit.complexity: 3
 * audit.doc_status: "enriched"
 * audit.last_reviewed: "2026-03-02"
 * ---
 */
{ config, lib, pkgs, ... }:
# ... eigentlicher Nix-Code
```

## In der .md-Datei (identisches Frontmatter, erweitert)

```markdown
---
id: "NIXH-40-MEDIA-001"
title: "Jellyfin Media Server"
description: "Hardware-accelerated media streaming with declarative QSV/iHD transcoding"
layer: 40
nixpkgs.category: "servers/media"
capabilities.hardware:
  - "gpu/intel-qsv"
  - "gpu/opencl"
capabilities.ingress:
  - "caddy/reverse-proxy"
  - "tailscale/trusted"
architecture.upstream:
  - "NIXH-00-CORE-001"
  - "NIXH-00-CORE-002"
  - "NIXH-20-SERVER-001"
resources.port: 20096
ref.code: "40-media/jellyfin.nix"
audit.complexity: 3
audit.doc_status: "enriched"
audit.last_reviewed: "2026-03-02"
---

# Jellyfin Media Server
[... Dokumentationsinhalt ...]
```

**Wichtig:** Die Felder in `.nix` (Kurzform) und `.md` (Langform) sind
identisch. Ein Skript kann beide Richtungen synchronisieren.

---

# TEIL 2: DIE KI-REFAKTORIERUNGS-STRATEGIE

## Das Grundproblem mit 650 Dokumenten

650 Docs × Ø 2.000 Wörter = 1.300.000 Wörter.
Das passt niemals in ein Kontextfenster.

**Lösung: Chunking → Indexing → Targeted Retrieval**

```
Phase 0: Split       → 650 Dateien werden in strukturierte Chunks zerlegt
Phase 1: Index       → Jeder Chunk bekommt Keywords + Layer-Zuweisung
Phase 2: Match       → Pro Ziel-.nix wird der relevante Chunk-Pool geholt
Phase 3: Synthesize  → KI schreibt .md aus Nix-Code + Chunk-Pool
Phase 4: Validate    → Isomorphie-Check: ref.code stimmt, ID eindeutig
```

---

## Phase 0: Chunking-Skript

Das Skript zerlegt die 650 Dateien in einzelne Chunks mit extrahierten Keywords.
Jeder Chunk landet als JSON-Zeile in einem Index.

```bash
#!/bin/bash
# chunk_and_index.sh
# Zerlegt 650 Docs → chunk_index.jsonl

CHAOS_DIR="./chaos_docs"       # Deine 650 Dateien
INDEX_FILE="./chunk_index.jsonl"
CHUNK_DIR="./chunks"

mkdir -p "$CHUNK_DIR"
> "$INDEX_FILE"

CHUNK_ID=0

for doc in "$CHAOS_DIR"/*.md "$CHAOS_DIR"/*.txt; do
  [ -e "$doc" ] || continue
  
  filename=$(basename "$doc")
  content=$(cat "$doc")
  
  # Keywords aus Dateiname + Inhalt extrahieren
  # Nutze dein existierendes doc_tagger.sh Gewichtungsschema!
  keywords=$(echo "$content" | \
    grep -oiE '\b(jellyfin|sonarr|radarr|caddy|tailscale|sops|adguard|
                  postgresql|paperless|miniflux|monica|vaultwarden|n8n|
                  matrix|ollama|netdata|scrutiny|uptime|kuma|zigbee|
                  wireguard|vpn|firewall|ssh|kernel|storage|mergerfs|
                  backup|restic|flake|home-manager|secrets|age)\b' | \
    sort -u | tr '\n' ',' | sed 's/,$//')
  
  # Layer-Zuweisung basierend auf Keywords
  layer="99"  # Default: unsortiert
  echo "$keywords" | grep -qiE 'kernel|ssh|firewall|boot|storage|backup|sops' && layer="00"
  echo "$keywords" | grep -qiE 'caddy|adguard|tailscale|postgresql|valkey|vpn' && layer="20"
  echo "$keywords" | grep -qiE 'vaultwarden|n8n|home.assistant|matrix|ollama' && layer="30"
  echo "$keywords" | grep -qiE 'jellyfin|sonarr|radarr|lidarr|sabnzbd|arr' && layer="40"
  echo "$keywords" | grep -qiE 'paperless|miniflux|monica|readeck|karakeep' && layer="50"
  echo "$keywords" | grep -qiE 'netdata|scrutiny|uptime.kuma|monitoring' && layer="80"
  
  # JSON-Zeile in Index schreiben
  printf '{"id":%d,"source":"%s","layer":"%s","keywords":"%s","preview":"%s"}\n' \
    "$CHUNK_ID" \
    "$filename" \
    "$layer" \
    "$keywords" \
    "$(head -3 "$doc" | tr '\n' ' ' | sed 's/"/\\"/g' | cut -c1-200)" \
    >> "$INDEX_FILE"
  
  CHUNK_ID=$((CHUNK_ID + 1))
done

echo "Index erstellt: $(wc -l < "$INDEX_FILE") Chunks in $INDEX_FILE"
```

---

## Phase 1: Lookup-Skript (Targeted Retrieval)

Für jede Ziel-`.nix`-Datei werden nur die relevanten Chunks geholt.
Nicht 650 Docs — sondern 5-15 relevante Chunks.

```bash
#!/bin/bash
# get_relevant_chunks.sh <service_name>
# Gibt die relevantesten Chunks für einen Service zurück

SERVICE="$1"   # z.B. "jellyfin"
INDEX="./chunk_index.jsonl"
CHUNKS="./chunks"
MAX_CHUNKS=8   # Kontextfenster schonen: max 8 Chunks pro Durchgang

echo "=== Relevante Chunks für: $SERVICE ==="

# Exact match zuerst, dann fuzzy
grep -i "\"$SERVICE\"" "$INDEX" | head -3
grep -i "$SERVICE" "$INDEX" | grep -v "\"$SERVICE\"" | head -$((MAX_CHUNKS - 3))
```

---

## Phase 2: Der KI-Prompt-Template

Das ist der entscheidende Teil. Der Prompt ist so gebaut, dass:
1. Das Kontextfenster nicht explodiert (nur relevante Chunks)
2. Die KI keine Halluzinationen einbaut (Nix-Code als Anker)
3. Das Ergebnis direkt SSOT-konform ist

```
========================================================
SYSTEM PROMPT (einmalig gesetzt, ändert sich nicht)
========================================================

Du bist ein NixOS-Dokumentations-Spezialist.
Deine Aufgabe: Erstelle isomorphe .md-Dokumentation zu .nix-Modulen.

REGELN:
1. Der NMS-Header im .nix-Code ist SSOT. Kopiere ihn 1:1 ins .md-Frontmatter.
2. Ergänze aus den Kontext-Chunks NUR verifiziertes Wissen.
3. Erfinde NICHTS. Wenn du es nicht weißt: audit.doc_status: "draft"
4. Struktur der .md ist IMMER:
   - YAML Frontmatter (aus .nix kopiert)
   - ## Was macht das Modul? (1-2 Sätze, aus description)
   - ## Wie funktioniert es? (technische Details aus Nix-Code)
   - ## Warum so konfiguriert? (Wissen aus Kontext-Chunks)
   - ## Abhängigkeiten (aus architecture.upstream)
   - ## Offene Punkte (aus audit.open_issues)

NMS-VERSION: 2.3
REPO-STRUKTUR: 00-core|20-server|30-services|40-media|50-knowledge|80-monitoring|90-policy

========================================================
USER PROMPT (pro Modul, mit Kontext-Chunks)
========================================================

## AUFGABE: Dokumentiere jellyfin.nix

### NIX-CODE (SSOT — nicht verändern):
```nix
[VOLLSTÄNDIGER INHALT VON 40-media/jellyfin.nix]
```

### KONTEXT-CHUNKS (Wissen aus alten Dokumenten):
--- Chunk 1 (Quelle: 23_jellyfin_qsv_setup.md) ---
[INHALT]

--- Chunk 2 (Quelle: 47_hardware_transcoding.md) ---
[INHALT]

--- Chunk 3 (Quelle: 112_media_stack_overview.md) ---
[INHALT]

### ERWARTETES ERGEBNIS:
Erstelle 40-media/jellyfin.md mit:
- YAML-Frontmatter identisch zum NMS-Header in jellyfin.nix
- Vollständig ausgefüllte Sektionen basierend auf Code + Chunks
- audit.doc_status: "enriched" wenn Chunks verwendet, "draft" wenn nicht
========================================================
```

---

## Phase 3: Die Batch-Pipeline

Das Automatisierungsskript das alles zusammenbringt:

```bash
#!/bin/bash
# nixhome_ai_refactor.sh
# Orchestriert die KI-Refaktorierung aller Module

REPO="/etc/nixos"
OBSIDIAN="./obsidian_vault"
INDEX="./chunk_index.jsonl"
LOG="./refactor_log.jsonl"

# Layer-Mapping: Ordner → Layer-Nummer
declare -A LAYER_MAP=(
  ["00-core"]="00-CORE"
  ["20-server"]="20-SERVER"
  ["30-services"]="30-SVC"
  ["40-media"]="40-MEDIA"
  ["50-knowledge"]="50-KNOW"
  ["80-monitoring"]="80-MON"
  ["90-policy"]="90-POL"
)

# Verarbeitungsreihenfolge: kritische Layer zuerst
LAYER_ORDER=("00-core" "20-server" "30-services" "40-media" "50-knowledge" "80-monitoring")

mkdir -p "$OBSIDIAN"

for layer_dir in "${LAYER_ORDER[@]}"; do
  layer_num="${LAYER_MAP[$layer_dir]}"
  mkdir -p "$OBSIDIAN/$layer_dir"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▶ Layer: $layer_dir ($layer_num)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  module_num=0
  for nix_file in "$REPO/$layer_dir"/*.nix; do
    [ -e "$nix_file" ] || continue
    
    # Interne Helper überspringen
    basename "$nix_file" | grep -q '^_' && continue
    
    module_num=$((module_num + 1))
    base=$(basename "$nix_file" .nix)
    md_file="$OBSIDIAN/$layer_dir/$base.md"
    
    # NMS-ID generieren falls nicht vorhanden
    nms_id="NIXH-${layer_num}-$(echo "$base" | tr '[:lower:]-' '[:upper:]_')-$(printf '%03d' $module_num)"
    
    # Relevante Chunks holen (max 8, schont Kontextfenster)
    chunks=$(grep -i "$base\|$(echo $base | tr '-' '|')" "$INDEX" 2>/dev/null | head -8)
    
    # Status loggen
    printf '{"module":"%s","id":"%s","chunks":%d,"timestamp":"%s"}\n' \
      "$base" "$nms_id" "$(echo "$chunks" | wc -l)" "$(date -Iseconds)" \
      >> "$LOG"
    
    echo "  → $base (ID: $nms_id, Chunks: $(echo "$chunks" | grep -c .))"
    
    # Stub .md erstellen falls nicht vorhanden (AI füllt später)
    if [ ! -f "$md_file" ]; then
      nix_header=$(grep -A 20 '^\s*/\*\*' "$nix_file" | head -25)
      cat > "$md_file" << STUB
---
id: "$nms_id"
title: "$base"
layer: ${layer_dir%%'-'*}
ref.code: "$layer_dir/$base.nix"
audit.doc_status: "stub"
audit.last_reviewed: "$(date +%Y-%m-%d)"
---

# $base

## Was macht das Modul?
<!-- KI: Aus description in $base.nix extrahieren -->

## Wie funktioniert es?
<!-- KI: Aus Nix-Code + Chunks synthetisieren -->

## Warum so konfiguriert?
<!-- KI: Aus Kontext-Chunks anreichern -->
<!-- CHUNKS: $chunks -->

## Abhängigkeiten
<!-- KI: Aus architecture.upstream im Header -->

STUB
    fi
  done
done

echo ""
echo "✅ Stubs erstellt. Nächster Schritt: KI-Anreicherung mit:"
echo "   cat refactor_log.jsonl | jq '.module' | sort | uniq"
```

---

# TEIL 3: OBSIDIAN-INTEGRATION

## Die Vault-Struktur (spiegelt Repo 1:1)

```
obsidian_vault/
├── 00-core/
│   ├── configs.md          ← gespiegelt von 00-core/configs.nix
│   ├── ports.md
│   └── ...
├── 20-server/
│   ├── caddy.md
│   └── ...
├── 40-media/
│   ├── jellyfin.md
│   └── ...
│
├── _meta/                  ← Obsidian-spezifische Übersichtsseiten
│   ├── HOME.md             ← Startseite mit Layer-Übersicht
│   ├── DEPENDENCY_MAP.md   ← Auto-generiert aus architecture.upstream
│   └── AUDIT_RADAR.md      ← Status aller Module
│
└── 99-archive/             ← Die 650 alten Docs (unverändert, nur archiviert)
    ├── raw/                ← Originale
    └── processed/          ← Verarbeitet (status: processed)
```

---

## Dataview-Queries (sofort nutzbar nach Migration)

```markdown
# _meta/AUDIT_RADAR.md

## 🔴 Stubs — Brauchen KI-Anreicherung
```dataview
TABLE title, layer, ref.code
FROM ""
WHERE audit.doc_status = "stub"
SORT layer ASC
```

## 🟡 Drafts — Teilweise dokumentiert
```dataview
TABLE title, audit.complexity, audit.last_reviewed
FROM ""
WHERE audit.doc_status = "draft"
SORT audit.complexity DESC
```

## 🟢 Complete — Fertig
```dataview
TABLE title, nixpkgs.category, resources.port
FROM ""
WHERE audit.doc_status = "complete"
SORT layer ASC
```

## 🔍 Hardware Acceleration
```dataview
TABLE title, capabilities.hardware
FROM ""
WHERE contains(capabilities.hardware, "gpu/intel-qsv")
```

## 📡 Alle Services hinter Caddy
```dataview
TABLE title, resources.port, layer
FROM ""
WHERE contains(capabilities.ingress, "caddy/reverse-proxy")
SORT resources.port ASC
```
```

---

# TEIL 4: SYNCHRONISIERUNGS-WORKFLOW

## Wenn du eine .nix-Datei änderst

```
1. Ändere .nix-Header (neuer Port, neue Capability etc.)
2. Führe sync aus: bash nixhome_sync_header.sh 40-media/jellyfin.nix
3. Skript aktualisiert automatisch obsidian_vault/40-media/jellyfin.md
4. git commit -am "sync: jellyfin header updated"
```

## Das Sync-Skript

```bash
#!/bin/bash
# nixhome_sync_header.sh <nix_file>
# Synchronisiert NMS-Header von .nix → .md

NIX_FILE="$1"
OBSIDIAN="./obsidian_vault"

# Pfad ableiten
rel_path="${NIX_FILE#/etc/nixos/}"
md_file="$OBSIDIAN/${rel_path%.nix}.md"

# Header-Felder aus .nix extrahieren
extract_field() {
  grep -oP "$1: \K.*" "$NIX_FILE" | head -1 | tr -d '"'
}

id=$(extract_field "id")
title=$(extract_field "title")
layer=$(extract_field "layer")
port=$(extract_field "resources.port")
status=$(extract_field "audit.doc_status")

[ -z "$id" ] && echo "⚠ Kein NMS-Header in $NIX_FILE" && exit 1

# YAML-Frontmatter in .md aktualisieren (nur Header-Zeilen)
if [ -f "$md_file" ]; then
  # Existing fields updaten
  sed -i "s/^id: .*/id: \"$id\"/" "$md_file"
  sed -i "s/^title: .*/title: \"$title\"/" "$md_file"
  sed -i "s/^resources.port: .*/resources.port: $port/" "$md_file"
  echo "✅ Synchronisiert: $NIX_FILE → $md_file"
else
  echo "⚠ Kein .md gefunden: $md_file (führe erst nixhome_ai_refactor.sh aus)"
fi
```

---

# ZUSAMMENFASSUNG: DIE 5 SCHRITTE

```
SCHRITT 1: chunk_and_index.sh
  Input:  650 Chaos-Docs
  Output: chunk_index.jsonl (jede Datei = eine JSON-Zeile mit Keywords + Layer)
  Ziel:   Wissen indexieren ohne Kontextfenster zu sprengen

SCHRITT 2: nixhome_ai_refactor.sh (Stub-Modus)
  Input:  Alle .nix-Dateien aus /etc/nixos
  Output: obsidian_vault/**/*.md als leere Stubs mit korrekten IDs
  Ziel:   Gerüst erstellen das die KI befüllen kann

SCHRITT 3: KI-Anreicherung (manuell, layerweise)
  Input:  .nix Code + 8 relevante Chunks aus Index
  Output: Fertig dokumentierte .md-Dateien
  Prompt: Aus TEIL 2, Phase 2

SCHRITT 4: Obsidian-Import
  Input:  obsidian_vault/ Ordner
  Output: Obsidian Vault mit Dataview-Queries
  Ziel:   Durchsuchbare Knowledge-Base

SCHRITT 5: nixhome_sync_header.sh (laufend)
  Bei jeder .nix-Änderung: Header → .md synchronisieren
  Git-Hook möglich: pre-commit führt sync automatisch aus
```

---

# ID-SCHEMA (Referenz)

```
NIXH-{LAYER}-{KATEGORIE}-{NUMMER}

LAYER:
  00 = CORE       (OS-Fundament)
  20 = SERVER     (Erreichbarkeit)
  30 = SVC        (Services)
  40 = MEDIA      (Medien)
  50 = KNOW       (Wissen)
  80 = MON        (Monitoring)
  90 = POL        (Policy)

KATEGORIE: Kurzname des Moduls in GROSSBUCHSTABEN (max 12 Zeichen)
  CADDY, ADGUARD, JELLYFIN, PAPERLESS, VAULTWARDEN, ...

Beispiele:
  NIXH-00-CORE-001   → configs.nix    (SSoT Master)
  NIXH-00-CORE-002   → ports.nix      (Port Registry)
  NIXH-20-CADDY-001  → caddy.nix
  NIXH-40-JELLYFIN-001 → jellyfin.nix
  NIXH-50-PAPERLESS-001 → paperless.nix
```
