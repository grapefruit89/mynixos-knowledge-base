# [GUIDE]: GitHub Pattern-Mining Protokoll
# ID: [NUGGET-ARCH-001] | Status: MANDATORY | Stand: 10.03.2026

## 1. Ziel (User Layer)
Wir fressen nicht blind ganze GitHub-Accounts. Wir sieben das Gold (Patterns, Hardening, Struktur) aus den Repos der "Nix-Master" (Misterio77, vic, Mic92), ohne unsere eigene Pfad-Reinheit zu gefährden.

## 2. Der Filter-Workflow (Technical Layer)

### Schritt 1: Das Sieben (Filter)
Wenn ein GitHub-Account (z.B. @nix-community) übergeben wird, listet der Agent NUR Repos, die:
- `*.nix` Dateien enthalten.
- Tags wie `nixos`, `homelab` oder `flake` haben.
- In 2024/2025 aktiv waren.

### Schritt 2: Das Schürfen (Extraktion)
Vom Ziel-Repo werden NUR folgende Dateien gelesen:
- `README.md` (Konzept)
- `flake.nix` (Struktur)
- `modules/**/*.nix` oder `hosts/**/*.nix` (Logik)
- **VERBOTEN:** Quellcode (`src/`), Lock-Files, CI-Configs.

### Schritt 3: Die Analyse (Pattern)
Der Agent extrahiert:
1. **Modul-Struktur:** Wie sind die Layer aufgebaut?
2. **Options-Pattern:** Wie werden Services deklariert?
3. **Hardening-Tricks:** Besondere systemd-Sandboxing Kniffe.

## 3. Storage (Almanach-Integration)
Die Ergebnisse wandern als `[PATTERN-MINING: <repo>]` in den Reasoning-Layer unserer eigenen ADRs.
