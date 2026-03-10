# 🧠 [SERVICES]: Knowledge Management Pipeline (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir bauen ein "Gedächtnis" für deinen Server. Alles, was wir in Chats besprechen oder was in Anleitungen im Internet steht, wird gesammelt, sortiert und für später aufbewahrt.
- **Problem:** Man vergisst schnell, warum man eine bestimmte Einstellung gemacht hat, oder findet eine gute Anleitung nicht wieder.
- **Lösung:** Eine automatisierte Pipeline. Sie nimmt Texte (Chats, Notizen, GitHub-Codes) und sortiert sie in Ordner wie "ADRs" (Entscheidungen) oder "Services" (Anleitungen).
- **Vorteil:** Du hast dein gesamtes Wissen an einem Ort. Wenn du wissen willst, wie du Jellyfin abgesichert hast, findest du sofort die Antwort.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation der Wissens-Infrastruktur.

### 🔄 2.1 Pipeline-Phasen
1.  **Ingestion:** Import von Claude-JSON-Exports, GitHub-Zips und eigenen Notizen in den `/raw/` Ordner.
2.  **Processing:**
    - **Chunking:** Aufteilung langer Texte in semantische Einheiten (~500 Tokens).
    - **Metadaten:** Generierung von YAML-Headern mit Top-Words (TF-IDF), Datum und Quelle.
    - **Deduplizierung:** SHA256-Hashing für exakte Duplikate und Jaccard-Similarität für "Fuzzy-Matches".
3.  **Storage:** Ablage der veredelten Markdown-Dateien in `/docs/` gemäß dem Drei-Layer-Standard.
4.  **Index:** Volltextsuche via `ripgrep` / `fzf` oder Meilisearch.

### 🛠️ 2.2 Hierarchie der Wahrheiten
1.  **Lokal (Eigene Docs):** Höchste Priorität. Enthält deine persönlichen Entscheidungen.
2.  **Nixpkgs Options:** Die Wahrheit über das technisch Mögliche.
3.  **Context7:** Aktuelle Library-Dokumentation.
4.  **Brave Search:** Gezielte Recherche für aktuelle Release-Notes (NixOS-only Filter).

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Wissens-Kompilation:** Das Ziel ist nicht nur ein Archiv, sondern ein Generierungssystem. Die KI nutzt dieses Wissen, um perfekt kommentierte `.nix` Dateien zu schreiben.
- **Transparenz:** Kein "Black Box" RAG. Der Nutzer kann jederzeit sehen, welcher Chunk in den Prompt ging (Deterministisch).
- **Zukunft:** Das System wächst mit jedem Chat und wird zum "persönlichen Ingenieur-Assistenten", der deine Präferenzen (z.B. sops-nix Standard) aus der Historie kennt.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-02 Homeserver mit Cloudflare sicher einrichten.md` (6.3.2026).
