# [ADR-030]: Metadata-Tagging Standard (Paperless & SRE)
# ID: [ADR-030] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir führen einen einheitlichen Standard für Datei-Metadaten ein. Jede Datei, die in unsere "Erzmine" gelangt, soll automatisch verschlagwortet werden, damit sie später in Paperless oder im Almanach ohne manuelles Suchen gefunden wird.

## 2. Technical Layer
- **Format:** YAML-Header in Markdown oder XMP-Tags in PDFs.
- **Tags:** `nms_id`, `layer`, `status`, `source_id`.
- **Automatismus:** Ein Python-Agent (`goldmine_extractor.py`) scannt die `/home/Knowledge-Pipeline/Erzmine/00-INBOX/` und schlägt Tags vor.

## 3. Reasoning Layer
- **Warum?** Bei tausenden Dokumenten im Home-Server wird man ohne maschinenlesbare Tags blind.
- **Integration:** Paperless-ngx liest diese Tags nativ aus und ordnet die Dokumente den richtigen Korrespondenten zu.

---
> [SOURCE]: /root/mynixos_full_goldmine.md
