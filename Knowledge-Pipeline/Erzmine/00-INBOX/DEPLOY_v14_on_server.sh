#!/usr/bin/env bash
# Führe dieses Skript AUF DEM SERVER als root aus.
# Es archiviert alle Vorgänger und aktiviert v14.0.
set -euo pipefail

OLD_GEMINI_DIR="/home/Knowledge-Pipeline/oldGeminis"
ARCHIVE_DIR="/home/Knowledge-Pipeline/Erzmine/02-ARCHIVE/versions"
WERKSTATT="/home/Werkstatt"
mkdir -p "$OLD_GEMINI_DIR"

echo "📦 Archiviere historische Verfassungen nach $OLD_GEMINI_DIR..."

for version in v7.0 v10.0 v11.0 v12.0; do
  src="$ARCHIVE_DIR/GEMINI_${version}.md"
  [ -f "$src" ] && cp "$src" "$OLD_GEMINI_DIR/" && echo "  ✅ ${version}" || echo "  ⚠️  ${version} nicht gefunden: $src"
done

[ -f "$WERKSTATT/GEMINI.md" ] && \
  cp "$WERKSTATT/GEMINI.md" "$OLD_GEMINI_DIR/GEMINI_v13.0_legacy.md" && \
  echo "  ✅ v13.0 (aktuelle Werkstatt-Kopie gesichert)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/GEMINI_v14.0.md" "$WERKSTATT/GEMINI.md"
cp "$SCRIPT_DIR/GEMINI_v14.0.md" "/home/Knowledge-Pipeline/Almanach/GEMINI.md"

echo ""
echo "📋 Museum-Inhalt ($OLD_GEMINI_DIR):"
ls -lh "$OLD_GEMINI_DIR"

echo ""
echo "🧹 Reinheits-Nachweis /root/:"
ls -la /root/

echo ""
echo "✅ GEMINI.md v14.0 ist jetzt aktiv in:"
echo "   $WERKSTATT/GEMINI.md"
echo "   /home/Knowledge-Pipeline/Almanach/GEMINI.md"
