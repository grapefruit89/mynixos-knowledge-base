#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# nixhome_sync_header.sh — Laufende Synchronisierung
#
# Synchronisiert NMS-Header bidirektional:
#   nix → md  (Standard: nach Code-Änderungen)
#   md  → nix (Optional: nach Docs-Änderungen)
#
# Usage:
#   bash nixhome_sync_header.sh 40-media/jellyfin.nix       # nix→md
#   bash nixhome_sync_header.sh --all                       # alle sync
#   bash nixhome_sync_header.sh --check                     # nur prüfen
#
# Als Git Pre-Commit Hook:
#   ln -s ../../nixhome_sync_header.sh .git/hooks/pre-commit
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

REPO="${NIXHOME_REPO:-/etc/nixos}"
OBSIDIAN="${NIXHOME_VAULT:-./obsidian_vault}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

# ── HELPER ────────────────────────────────────────────────────────
get_field() {
  # Extrahiert Feld aus NMS-Header (/** ... */ Block)
  local file="$1" field="$2"
  grep -oP "^\s*\*\s+$field:\s*\K.*" "$file" 2>/dev/null | \
    head -1 | tr -d '"' | xargs 2>/dev/null || echo ""
}

set_yaml_field() {
  # Setzt Feld in YAML-Frontmatter einer .md-Datei
  local file="$1" field="$2" value="$3"
  if grep -q "^$field:" "$file" 2>/dev/null; then
    sed -i "s|^$field:.*|$field: \"$value\"|" "$file"
  else
    # Feld vor dem schließenden --- einfügen
    sed -i "0,/^---$/{s|^---$|$field: \"$value\"\n---|}" "$file"
  fi
}

# ── FUNKTION: EINZELNE DATEI SYNCHEN ─────────────────────────────
sync_one() {
  local nix_file="$1"
  
  # Relativen Pfad ableiten
  local rel="${nix_file#$REPO/}"
  rel="${rel#./}"
  local md_file="$OBSIDIAN/${rel%.nix}.md"
  
  if [ ! -f "$nix_file" ]; then
    echo -e "${RED}✗ Nicht gefunden: $nix_file${NC}"
    return 1
  fi
  
  # Header-Felder aus .nix lesen
  local id; id=$(get_field "$nix_file" "id")
  local title; title=$(get_field "$nix_file" "title")
  local desc; desc=$(get_field "$nix_file" "description")
  local layer; layer=$(get_field "$nix_file" "layer")
  local port; port=$(get_field "$nix_file" "resources.port")
  local category; category=$(get_field "$nix_file" "nixpkgs.category")
  local complexity; complexity=$(get_field "$nix_file" "audit.complexity")
  local doc_status; doc_status=$(get_field "$nix_file" "audit.doc_status")
  
  if [ -z "$id" ]; then
    echo -e "${YELLOW}⚠ Kein NMS-Header in: $nix_file${NC}"
    echo "  → Bitte Header hinzufügen (siehe NIXHOME_ISOMORPHIE_STRATEGIE.md)"
    return 0
  fi
  
  if [ ! -f "$md_file" ]; then
    echo -e "${YELLOW}⚠ Kein .md für: $(basename "$nix_file")${NC}"
    echo "  → Führe erst nixhome_ai_refactor.sh aus"
    return 0
  fi
  
  # Felder in .md aktualisieren
  local changed=false
  local old_id; old_id=$(grep "^id:" "$md_file" | head -1 | sed 's/id: //' | tr -d '"')
  
  [ -n "$id" ] && { set_yaml_field "$md_file" "id" "$id"; changed=true; }
  [ -n "$title" ] && set_yaml_field "$md_file" "title" "$title"
  [ -n "$desc" ] && set_yaml_field "$md_file" "description" "$desc"
  [ -n "$layer" ] && set_yaml_field "$md_file" "layer" "$layer"
  [ -n "$port" ] && set_yaml_field "$md_file" "resources.port" "$port"
  [ -n "$category" ] && set_yaml_field "$md_file" "nixpkgs.category" "$category"
  [ -n "$complexity" ] && set_yaml_field "$md_file" "audit.complexity" "$complexity"
  
  # last_reviewed immer auf heute setzen
  set_yaml_field "$md_file" "audit.last_reviewed" "$(date +%Y-%m-%d)"
  
  echo -e "${GREEN}✓${NC} $(basename "$nix_file") → $(basename "$md_file") (ID: $id)"
  
  return 0
}

# ── FUNKTION: ALLE SYNCHEN ────────────────────────────────────────
sync_all() {
  local synced=0 skipped=0 errors=0
  
  echo -e "${BLUE}Synchronisiere alle NMS-Header...${NC}"
  echo ""
  
  local layers=("00-core" "20-server" "30-services" "40-media" "50-knowledge" "80-monitoring" "90-policy")
  
  for layer_dir in "${layers[@]}"; do
    [ -d "$REPO/$layer_dir" ] || continue
    
    for nix_file in "$REPO/$layer_dir"/*.nix; do
      [ -e "$nix_file" ] || continue
      [[ "$(basename "$nix_file")" == _* ]] && continue
      
      if sync_one "$nix_file"; then
        synced=$((synced + 1))
      else
        errors=$((errors + 1))
      fi
    done
  done
  
  echo ""
  echo "  Synchronisiert: $synced"
  [ $errors -gt 0 ] && echo -e "  ${RED}Fehler: $errors${NC}"
}

# ── FUNKTION: NUR PRÜFEN (KEIN SCHREIBEN) ────────────────────────
check_all() {
  echo -e "${BLUE}Isomorphie-Check (kein Schreiben)...${NC}"
  echo ""
  
  local ok=0 missing_header=0 missing_md=0 drift=0
  
  for layer_dir in 00-core 20-server 30-services 40-media 50-knowledge 80-monitoring 90-policy; do
    [ -d "$REPO/$layer_dir" ] || continue
    
    for nix_file in "$REPO/$layer_dir"/*.nix; do
      [ -e "$nix_file" ] || continue
      [[ "$(basename "$nix_file")" == _* ]] && continue
      
      base=$(basename "$nix_file" .nix)
      md_file="$OBSIDIAN/$layer_dir/$base.md"
      
      nix_id=$(get_field "$nix_file" "id")
      
      if [ -z "$nix_id" ]; then
        echo -e "  ${YELLOW}NO_HEADER${NC} $layer_dir/$base.nix"
        missing_header=$((missing_header + 1))
        continue
      fi
      
      if [ ! -f "$md_file" ]; then
        echo -e "  ${RED}NO_MD${NC}     $layer_dir/$base.nix → $base.md fehlt"
        missing_md=$((missing_md + 1))
        continue
      fi
      
      md_id=$(grep "^id:" "$md_file" | head -1 | sed 's/id: //' | tr -d '"' | xargs)
      
      if [ "$nix_id" != "$md_id" ]; then
        echo -e "  ${RED}DRIFT${NC}     $base: .nix=$nix_id .md=$md_id"
        drift=$((drift + 1))
      else
        echo -e "  ${GREEN}OK${NC}        $base ($nix_id)"
        ok=$((ok + 1))
      fi
    done
  done
  
  echo ""
  echo "  ✓ OK:             $ok"
  echo "  ⚠ Kein Header:   $missing_header"
  echo "  ✗ Kein .md:       $missing_md"
  echo "  ✗ ID-Drift:       $drift"
  
  [ $((missing_header + missing_md + drift)) -gt 0 ] && return 1 || return 0
}

# ── MAIN ──────────────────────────────────────────────────────────
case "${1:-}" in
  --all)
    sync_all
    ;;
  --check)
    check_all
    ;;
  --help|-h)
    echo "Usage:"
    echo "  $0 40-media/jellyfin.nix   # Eine Datei synchen"
    echo "  $0 --all                   # Alle synchen"
    echo "  $0 --check                 # Nur prüfen (kein Schreiben)"
    ;;
  "")
    # Als Git Pre-Commit Hook: staged .nix-Dateien synchen
    staged=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep '\.nix$' || true)
    if [ -n "$staged" ]; then
      echo -e "${BLUE}Pre-Commit: NMS-Header sync...${NC}"
      echo "$staged" | while read -r f; do
        sync_one "$REPO/$f" || true
      done
      # Geänderte .md-Dateien stagen
      git add "$OBSIDIAN" 2>/dev/null || true
    fi
    ;;
  *)
    # Einzelne Datei
    sync_one "$1"
    ;;
esac
