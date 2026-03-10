#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# nixhome_ai_refactor.sh — Phase 2+3 der Pipeline
#
# 1. Erstellt .md-Stubs für alle .nix-Module (sofort)
# 2. Generiert KI-Prompts mit relevanten Chunks (für manuelle KI-Anreicherung)
#
# Usage: bash nixhome_ai_refactor.sh [repo_dir] [chunk_index]
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

REPO="${1:-/etc/nixos}"
INDEX="${2:-./chunk_index.jsonl}"
OBSIDIAN="${3:-./obsidian_vault}"
PROMPTS_DIR="./ai_prompts"
NMS_VERSION="2.3"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

# ── LAYER-KONFIGURATION ───────────────────────────────────────────
declare -A LAYER_ID=(
  ["00-core"]="00-CORE"
  ["20-server"]="20-SERVER"
  ["30-services"]="30-SVC"
  ["40-media"]="40-MEDIA"
  ["50-knowledge"]="50-KNOW"
  ["80-monitoring"]="80-MON"
  ["90-policy"]="90-POL"
)

LAYER_ORDER=("00-core" "20-server" "30-services" "40-media" "50-knowledge" "80-monitoring" "90-policy")

# ── FUNKTION: HEADER AUS NIX EXTRAHIEREN ─────────────────────────
extract_nms_field() {
  local file="$1" field="$2"
  grep -oP "^\s*\*\s+$field:\s*\K.*" "$file" 2>/dev/null | head -1 | tr -d '"' || echo ""
}

# ── FUNKTION: RELEVANTE CHUNKS HOLEN ─────────────────────────────
get_chunks() {
  local service="$1" layer_prefix="$2" max="${3:-6}"
  
  if [ ! -f "$INDEX" ]; then echo ""; return; fi
  
  # Exakter Treffer zuerst, dann Layer-Match, dann fuzzy
  {
    # 1. Exakter Service-Name in Keywords
    grep -i "\"keywords\":\"[^\"]*$service" "$INDEX" 2>/dev/null | head -3
    # 2. Layer-Match
    grep "\"layer\":\"$layer_prefix\"" "$INDEX" 2>/dev/null | head -3
    # 3. Service im Dateinamen
    grep -i "\"source\":\"[^\"]*$service" "$INDEX" 2>/dev/null | head -2
  } | sort -u | head -$max
}

# ── FUNKTION: STUB ERSTELLEN ──────────────────────────────────────
create_stub() {
  local nix_file="$1" md_file="$2" nms_id="$3" title="$4" layer_num="$5" layer_dir="$6"
  
  # Felder aus vorhandenem Header lesen (falls schon vorhanden)
  local desc; desc=$(extract_nms_field "$nix_file" "description")
  local port; port=$(extract_nms_field "$nix_file" "resources.port")
  local category; category=$(extract_nms_field "$nix_file" "nixpkgs.category")
  local complexity; complexity=$(extract_nms_field "$nix_file" "audit.complexity")
  
  [ -z "$desc" ] && desc="Beschreibung fehlt — bitte ergänzen"
  [ -z "$port" ] && port="siehe ports.nix"
  [ -z "$category" ] && category="services/misc"
  [ -z "$complexity" ] && complexity="2"

  cat > "$md_file" << MDEOF
---
id: "$nms_id"
title: "$title"
description: "$desc"
layer: $layer_num
nixpkgs.category: "$category"
resources.port: $port
ref.code: "$layer_dir/$title.nix"
ref.doc: "$layer_dir/$title.md"
nms_version: "$NMS_VERSION"
audit.doc_status: "stub"
audit.complexity: $complexity
audit.last_reviewed: "$(date +%Y-%m-%d)"
---

# $title

## Was macht das Modul?
<!-- KI: Aus \`description\` und Nix-Code ableiten -->
$desc

## Wie funktioniert es?
<!-- KI: Technische Details aus $title.nix synthetisieren -->
<!-- Ports, Pfade, systemd-Konfiguration, Abhängigkeiten -->

## Warum so konfiguriert?
<!-- KI: Aus Kontext-Chunks anreichern -->
<!-- Designentscheidungen, Alternativen, bekannte Issues -->

## Abhängigkeiten
<!-- KI: Aus architecture.upstream im Nix-Header -->

| Modul | ID | Warum |
|---|---|---|
| configs.nix | NIXH-00-CORE-001 | SSoT Master |
| ports.nix | NIXH-00-CORE-002 | Port-Registry |

## Offene Punkte
<!-- KI: Aus audit.open_issues -->

---
*Generiert von nixhome_ai_refactor.sh — Status: stub*
MDEOF
}

# ── FUNKTION: KI-PROMPT GENERIEREN ───────────────────────────────
generate_ai_prompt() {
  local nix_file="$1" md_file="$2" chunks="$3" title="$4" nms_id="$5"
  local prompt_file="$PROMPTS_DIR/$title.txt"
  
  cat > "$prompt_file" << PROMPT
========================================================
NMS KI-REFAKTORIERUNGS-PROMPT
Modul: $title
ID: $nms_id
========================================================

Du bist ein NixOS-Dokumentations-Spezialist.
Fülle die .md-Stub-Datei mit konkretem Wissen.

REGELN:
1. Kopiere den YAML-Header 1:1 — ändere NUR audit.doc_status
2. Erfinde NICHTS. Nur was aus Code oder Chunks ableitbar ist.
3. Wenn Chunks leer: audit.doc_status: "draft" (nicht "enriched")
4. Deutsch schreiben, technische Begriffe auf Englisch lassen
5. Keine Markdown-Backtick-Blöcke für Code-Snippets — inline \`code\`

════════════════════════════════════════════════════════
NIX-CODE (SSOT — ist die absolute Wahrheit):
════════════════════════════════════════════════════════
$(cat "$nix_file" 2>/dev/null || echo "[Datei nicht gefunden: $nix_file]")

════════════════════════════════════════════════════════
AKTUELLE STUB-DATEI (diese befüllen):
════════════════════════════════════════════════════════
$(cat "$md_file" 2>/dev/null || echo "[Stub nicht gefunden]")

════════════════════════════════════════════════════════
KONTEXT-CHUNKS AUS ALTEN DOKUMENTEN:
════════════════════════════════════════════════════════
$(if [ -n "$chunks" ]; then
  echo "$chunks" | while IFS= read -r chunk_line; do
    source=$(echo "$chunk_line" | grep -oP '"source":"\K[^"]+')
    preview=$(echo "$chunk_line" | grep -oP '"preview":"\K[^"]+')
    echo "--- Quelle: $source ---"
    echo "$preview"
    echo ""
  done
else
  echo "[Keine relevanten Chunks gefunden — aus Code ableiten]"
fi)

════════════════════════════════════════════════════════
ERWARTETES ERGEBNIS:
Gib die vollständig ausgefüllte $title.md zurück.
Setze audit.doc_status auf:
  "enriched"  wenn Chunks verwendet wurden
  "draft"     wenn nur Code als Quelle vorhanden
  "complete"  wenn du sicher bist dass nichts fehlt
========================================================
PROMPT

  echo "$prompt_file"
}

# ── HAUPTPROGRAMM ─────────────────────────────────────────────────
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  NIXHOME KI-Refaktorierung — Phase 2+3${NC}"
echo -e "${BLUE}  Repo: $REPO${NC}"
echo -e "${BLUE}  Vault: $OBSIDIAN${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

mkdir -p "$PROMPTS_DIR"
mkdir -p "$OBSIDIAN/_meta"

total_modules=0
total_chunks_found=0

for layer_dir in "${LAYER_ORDER[@]}"; do
  [ -d "$REPO/$layer_dir" ] || continue
  
  layer_num="${layer_dir%%-*}"
  layer_short="${LAYER_ID[$layer_dir]:-$layer_dir}"
  
  mkdir -p "$OBSIDIAN/$layer_dir"
  
  echo ""
  echo -e "${CYAN}▶ $layer_dir${NC}"

  module_num=0
  for nix_file in "$REPO/$layer_dir"/*.nix; do
    [ -e "$nix_file" ] || continue
    
    base=$(basename "$nix_file" .nix)
    
    # Interne Helper (_lib.nix, _imports.nix) überspringen
    [[ "$base" == _* ]] && continue
    
    module_num=$((module_num + 1))
    total_modules=$((total_modules + 1))
    
    md_file="$OBSIDIAN/$layer_dir/$base.md"
    
    # NMS-ID aus existierendem Header oder neu generieren
    existing_id=$(extract_nms_field "$nix_file" "id")
    if [ -n "$existing_id" ]; then
      nms_id="$existing_id"
    else
      nms_id="NIXH-${layer_short}-$(echo "$base" | tr '[:lower:]-' '[:upper:]_' | cut -c1-12)-$(printf '%03d' $module_num)"
    fi
    
    # Titel aus Header oder Dateiname
    title_raw=$(extract_nms_field "$nix_file" "title")
    title="${title_raw:-$base}"
    
    # Relevante Chunks aus Index holen
    chunks=$(get_chunks "$base" "$layer_num" 6)
    chunk_count=$(echo "$chunks" | grep -c . || echo 0)
    total_chunks_found=$((total_chunks_found + chunk_count))
    
    # Stub erstellen (falls nicht schon vorhanden mit echtem Inhalt)
    if [ ! -f "$md_file" ] || grep -q 'doc_status: "stub"' "$md_file" 2>/dev/null; then
      create_stub "$nix_file" "$md_file" "$nms_id" "$base" "$layer_num" "$layer_dir"
      stub_created=true
    else
      stub_created=false
    fi
    
    # KI-Prompt generieren
    prompt_file=$(generate_ai_prompt "$nix_file" "$md_file" "$chunks" "$base" "$nms_id")
    
    # Status ausgeben
    if $stub_created; then
      echo -e "  ${GREEN}✓${NC} $base ($nms_id) — $chunk_count Chunks → $prompt_file"
    else
      echo -e "  ${YELLOW}↻${NC} $base — bereits vorhanden, Prompt regeneriert"
    fi
  done
done

# ── AUDIT-RADAR GENERIEREN ────────────────────────────────────────
cat > "$OBSIDIAN/_meta/AUDIT_RADAR.md" << 'RADAR'
---
title: "Audit Radar"
description: "Automatisch generierte Übersicht aller NMS-Module"
---

# 🛰️ Audit Radar

## 🔴 Stubs — Brauchen KI-Anreicherung
```dataview
TABLE title, layer, ref.code, audit.complexity AS "Komplexität"
FROM ""
WHERE audit.doc_status = "stub"
SORT layer ASC, audit.complexity DESC
```

## 🟡 Drafts — Teilweise dokumentiert
```dataview
TABLE title, audit.complexity AS "Komplexität", audit.last_reviewed AS "Zuletzt"
FROM ""
WHERE audit.doc_status = "draft"
SORT audit.complexity DESC
```

## 🟢 Enriched/Complete — Gut dokumentiert
```dataview
TABLE title, nixpkgs.category AS "Kategorie", resources.port AS "Port"
FROM ""
WHERE audit.doc_status = "enriched" OR audit.doc_status = "complete"
SORT layer ASC
```

## 🔍 Hardware Acceleration
```dataview
TABLE title, capabilities.hardware, layer
FROM ""
WHERE capabilities.hardware
```

## 📡 Services hinter Caddy
```dataview
TABLE title, resources.port AS "Port", layer
FROM ""
WHERE contains(capabilities.ingress, "caddy/reverse-proxy")
SORT resources.port ASC
```
RADAR

# ── ZUSAMMENFASSUNG ───────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Fertig!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Module verarbeitet: $total_modules"
echo "  Chunks gefunden:    $total_chunks_found"
echo "  Stubs erstellt in:  $OBSIDIAN/"
echo "  KI-Prompts in:      $PROMPTS_DIR/"
echo ""
echo "  Nächster Schritt — KI-Anreicherung:"
echo "    ls $PROMPTS_DIR/               # alle Prompts anzeigen"
echo "    cat $PROMPTS_DIR/jellyfin.txt  # Prompt für jellyfin"
echo ""
echo "  Dann: bash nixhome_sync_header.sh <nix_file>"
