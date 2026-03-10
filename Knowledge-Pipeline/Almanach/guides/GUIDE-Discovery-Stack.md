# [GUIDE]: Aviation-Grade Discovery Stack
# ID: [NUGGET-SRE-011] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & Zweck
Information Retrieval ist der Flaschenhals bei der Nix-Entwicklung. Wir integrieren spezialisierte "Discovery-Geister", um die Zeit von der Frage zur Lösung (MTTR - Mean Time To Resolution) auf ein Minimum zu reduzieren. Dieser Stack dient als Turbo für den "Context 7" Agenten.

## 2. Die Discovery-Geister

### 👻 1. Noogle (Nix API Search)
- **URL:** [noogle.dev](https://noogle.dev/)
- **Nutzen:** Suche nach Nix-Funktionen basierend auf Typ-Signaturen (z.B. `attrset -> string`).
- **Einsatz:** Wenn wir komplexe Library-Funktionen in der Werkstatt bauen.

### 👻 2. Searchix / NüschtOS
- **Nutzen:** Ultraschnelle Suche nach NixOS, Home-Manager und Darwin Optionen.
- **Vorteil:** Bessere Metadaten-Indizierung als die Standard-NixOS-Suche.

### 👻 3. nix-search-tv (CLI Fuzzy Finder)
- **Tool:** `pkgs.nix-search-tv`
- **Nutzen:** Rasendschnelle Suche nach Paketen direkt im Terminal.
- **Einsatz:** In der SRE-Shell integriert.

### 👻 4. Explainix (Visual Syntax)
- **Nutzen:** Visualisiert komplexe Nix-Ausdrücke.
- **Einsatz:** Analyse von "Legacy-Code" aus der Erzmine, um die logische Struktur zu verstehen.

## 3. High-Tier Hardening (saylesss88 Nuggets)
Wir übernehmen langfristig folgende Konzepte aus dem "Nix-Book":
- **Lanzaboote:** Signiertes Secure Boot für den Fujitsu Q958.
- **Root-on-tmpfs:** Maximale System-Hygiene (Impermanence). Das System wird bei jedem Boot "frisch" geboren.

## 4. Integration in die SRE-Shell
Ich ergänze die `shell.nix` um `nix-search-tv`, damit wir sofort loslegen können.

---
> [SOURCE]: saylesss88.github.io & nix-community/awesome-nix
