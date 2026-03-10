#!/usr/bin/env bash
# --- mynixos Traceability Audit Bot ---
# Prüft Dokumente auf Einhaltung des SRE Tor 7 Standards (Quellenpflicht)

DOCS_DIR="/home/Knowledge-Pipeline/docs"
MISSING_SOURCES=0

echo "🔍 Starte Aviation-Grade Traceability Audit..."
echo "------------------------------------------------"

for file in "$DOCS_DIR"/*.md; do
    filename=$(basename "$file")
    # Prüfe ob 'sources:' im YAML-Header vorhanden ist
    if ! grep -q "sources:" "$file"; then
        echo "❌ BUG DETECTED: $filename fehlt die Quellenangabe!"
        MISSING_SOURCES=$((MISSING_SOURCES + 1))
    fi
done

if [ $MISSING_SOURCES -eq 0 ]; then
    echo "✅ SUCCESS: Alle Dokumente sind ordnungsgemäß referenziert."
else
    echo "⚠️ WARNING: $MISSING_SOURCES Dokumente verletzen SRE Tor 7!"
fi
