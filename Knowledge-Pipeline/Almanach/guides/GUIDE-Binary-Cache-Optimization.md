---
title: 📦 Binary Cache Optimization (The 82% Saving)
category: architecture/storage
status: [PROPOSED]
capabilities: [binary-deduplication, git-backed-cache, storage-efficiency]
sources: [r/Nix, Nix Binary Cache Patterns 2026]
---

# 📦 Binary-Optimierung: Jedes Byte zählt

In mynixos ist der Speicherplatz auf Tier A (NVMe) kostbar. Wir nutzen moderne Deduplizierungs-Strategien, um den State unter 10GB zu halten.

## 🏛️ 1. Das Git-Backed Cache Konzept
Anstatt fertige Pakete einfach nur zu kopieren, nutzen wir ein Git-ähnliches Content-Addressing.
- **Nugget:** Identische Fragmente von Binaries (z.B. Library-Abhängigkeiten) werden nur einmal gespeichert.
- **Ergebnis:** Bis zu 82% weniger Platzverbrauch für deine lokalen Builds. ✅

## ⚙️ 2. Implementierung (SRE-Workflow)
Wir nutzen den Tower als lokalen Build-Server und optimieren den Store:
\`\`\`bash
# Manuelle Store-Optimierung
nix-store --optimize
# Aktivierung der automatischen Optimierung
nix.settings.auto-optimise-store = true;
\`\`\`

## 🔄 3. Offsite-Brücke
Durch die Reduzierung der Cache-Größe wird unser Cloud-Sync (Kapitel 80) massiv beschleunigt. Ein 10GB State wird so zu einem ~2GB Transfer-Paket.

## 🚀 SRE-Vorteil
Weniger I/O-Last schont deine NVMe und macht das Disaster Recovery (ADR-015) extrem schnell. Inmynixos ist Effizienz kein Zufall, sondern das Ergebnis von Deduplizierung.