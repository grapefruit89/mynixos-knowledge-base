#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# chunk_and_index.sh — Phase 0+1 der KI-Refaktorierungs-Pipeline
# Zerlegt 650 Chaos-Dokumente in einen durchsuchbaren Index
#
# Usage: bash chunk_and_index.sh [chaos_docs_dir]
# Output: chunk_index.jsonl, layer_stats.txt
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

CHAOS_DIR="${1:-./chaos_docs}"
INDEX_FILE="./chunk_index.jsonl"
STATS_FILE="./layer_stats.txt"

# ── FARBEN ────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

# ── KEYWORD-SETS PRO LAYER ────────────────────────────────────────
# Reihenfolge: spezifischste Keywords zuerst (gewinnen bei Konflikt)
KEYWORDS_40="jellyfin|sonarr|radarr|lidarr|readarr|prowlarr|sabnzbd|audiobookshelf|arr|recyclarr|jellyseerr|media.stack|transcod|qsv|vaapi"
KEYWORDS_50="paperless|miniflux|monica|readeck|karakeep|stirling.pdf|bookmark|crm|rss|feed|wissen|knowledge|dokument"
KEYWORDS_80="netdata|scrutiny|uptime.kuma|monitoring|smart|sensor|alert|dashboard|metr"
KEYWORDS_30="vaultwarden|n8n|home.assistant|zigbee|matrix|filebrowser|olivetin|cockpit|ollama|open.webui|automation"
KEYWORDS_20="caddy|adguard|tailscale|cloudflared|pocket.id|postgresql|valkey|vpn|confinement|dns|ddns|fail2ban|clamav|sso|proxy|tunnel"
KEYWORDS_00="kernel|ssh|firewall|boot|storage|mergerfs|backup|restic|sops|age|secret|nftables|users|locale|systemd.networkd|nix.gc|hardware"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  NIXHOME Chunk & Index — Phase 0+1${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ! -d "$CHAOS_DIR" ]; then
  echo -e "${RED}✗ Chaos-Dir nicht gefunden: $CHAOS_DIR${NC}"
  echo "  Usage: bash chunk_and_index.sh /pfad/zu/deinen/650/docs"
  exit 1
fi

> "$INDEX_FILE"

declare -A LAYER_COUNT=([00]=0 [20]=0 [30]=0 [40]=0 [50]=0 [80]=0 [99]=0)

total=0
chunk_id=0

while IFS= read -r -d '' doc; do
  total=$((total + 1))
  filename=$(basename "$doc")

  # Inhalt lesen (erste 150 Zeilen reichen für Keywords)
  content=$(head -150 "$doc" 2>/dev/null || echo "")
  combined="$filename $content"

  # Keywords extrahieren (gewichtet: Dateiname 3x, Headings 2x, Body 1x)
  fname_words=$(echo "$filename" | grep -oiE '[a-z]+' | tr '\n' ' ')
  headings=$(echo "$content" | grep '^#' | tr '\n' ' ')
  keywords_raw=$(echo "$fname_words $fname_words $fname_words $headings $headings $content" | \
    grep -oiE '\b(jellyfin|sonarr|radarr|lidarr|readarr|prowlarr|sabnzbd|audiobookshelf|
                    paperless|miniflux|monica|readeck|karakeep|
                    netdata|scrutiny|kuma|monitoring|
                    vaultwarden|n8n|home.assistant|zigbee|matrix|ollama|
                    caddy|adguard|tailscale|cloudflared|postgresql|valkey|vpn|dns|sso|
                    kernel|ssh|firewall|boot|storage|mergerfs|backup|restic|sops|age|
                    nix|nixos|flake|module|service|systemd)\b' 2>/dev/null | \
    sort | uniq -c | sort -rn | awk '{print $2}' | head -15 | tr '\n' ',' | sed 's/,$//')

  # Layer-Zuweisung (Priorität: spezifischer Layer gewinnt)
  layer="99"
  echo "$combined" | grep -qiE "$KEYWORDS_40" && layer="40"
  echo "$combined" | grep -qiE "$KEYWORDS_50" && layer="50"
  echo "$combined" | grep -qiE "$KEYWORDS_80" && layer="80"
  echo "$combined" | grep -qiE "$KEYWORDS_30" && layer="30"
  # 20 und 00 nur wenn kein spezifischerer Layer gefunden
  [ "$layer" = "99" ] && echo "$combined" | grep -qiE "$KEYWORDS_20" && layer="20"
  [ "$layer" = "99" ] && echo "$combined" | grep -qiE "$KEYWORDS_00" && layer="00"

  LAYER_COUNT[$layer]=$((${LAYER_COUNT[$layer]:-0} + 1))

  # Preview (erste nicht-leere Zeile nach Frontmatter)
  preview=$(echo "$content" | grep -v '^---' | grep -v '^$' | head -2 | tr '\n' ' ' | \
    sed 's/["\]/\\&/g' | cut -c1-180)

  # JSON-Zeile schreiben
  printf '{"id":%d,"source":"%s","layer":"%s","keywords":"%s","preview":"%s"}\n' \
    "$chunk_id" \
    "$(echo "$filename" | sed 's/"/\\"/g')" \
    "$layer" \
    "$keywords_raw" \
    "$preview" \
    >> "$INDEX_FILE"

  chunk_id=$((chunk_id + 1))

  # Fortschritt
  [ $((total % 50)) -eq 0 ] && echo -e "  ${CYAN}Verarbeitet: $total Dokumente...${NC}"

done < <(find "$CHAOS_DIR" -type f \( -name "*.md" -o -name "*.txt" \) -print0)

# ── STATISTIK ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Ergebnis${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Gesamt verarbeitet: $total Dokumente"
echo ""
echo "  Layer-Verteilung:"
echo "    00-core        → ${LAYER_COUNT[00]:-0} Docs"
echo "    20-server      → ${LAYER_COUNT[20]:-0} Docs"
echo "    30-services    → ${LAYER_COUNT[30]:-0} Docs"
echo "    40-media       → ${LAYER_COUNT[40]:-0} Docs"
echo "    50-knowledge   → ${LAYER_COUNT[50]:-0} Docs"
echo "    80-monitoring  → ${LAYER_COUNT[80]:-0} Docs"
echo "    99-unsorted    → ${LAYER_COUNT[99]:-0} Docs  ← manuell prüfen"

{
  echo "NIXHOME Chunk Index — $(date)"
  echo "Gesamt: $total"
  echo "00-core: ${LAYER_COUNT[00]:-0}"
  echo "20-server: ${LAYER_COUNT[20]:-0}"
  echo "30-services: ${LAYER_COUNT[30]:-0}"
  echo "40-media: ${LAYER_COUNT[40]:-0}"
  echo "50-knowledge: ${LAYER_COUNT[50]:-0}"
  echo "80-monitoring: ${LAYER_COUNT[80]:-0}"
  echo "99-unsorted: ${LAYER_COUNT[99]:-0}"
} > "$STATS_FILE"

echo ""
echo -e "  ${GREEN}✓ Index: $INDEX_FILE${NC}"
echo -e "  ${GREEN}✓ Stats: $STATS_FILE${NC}"
echo ""
echo "  Nächster Schritt:"
echo "    bash nixhome_ai_refactor.sh /etc/nixos ./chunk_index.jsonl"
