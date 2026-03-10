# [GUIDE]: Vimjoyer's Nix-Native Gems
# ID: [NUGGET-VIMJOYER-001] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & Prinzipien
Vimjoyer's Architektur zeichnet sich durch extrem hohe Portabilität und Robustheit aus. Jedes Tool bringt seine eigene Umgebung mit ("Wrapped Tools"). Wir übernehmen diese Konzepte, um den "Aviation-Grade" Standard zu untermauern.

## 2. Die Gold-Nuggets

### 🎁 1. Das Wrapped-Tool Muster (Binary Autarkie)
Anstatt Umgebungsvariablen global in der Shell zu setzen (was zu Seiteneffekten führt), werden Tools wie `nh` oder `neovim` direkt mit ihren Pfaden gewrapped.
- **Library:** `github:Lassulus/wrappers`
- **Anwendung:** `nh` wird fest mit der Variable `NH_FLAKE = "/home/Werkstatt"` verheiratet. Es funktioniert dann überall im System, ohne dass man im richtigen Ordner stehen muss.

### 🎁 2. Hybrid Neovim (Fast-Feedback DevMode)
Eines der größten Probleme bei Nix-nativem Neovim ist die langsame Iterationszeit (Edit -> Rebuild -> Test). Vimjoyer nutzt ein hybrides Modell:
- **Normaler Modus:** Alles ist Read-Only im Nix-Store (Aviation-Grade).
- **Dev-Modus:** Neovim liest seine Lua-Configs aus `~/nixconf/...`.
- **Der Clou:** Ein Shell-Script Wrapper (`neovimDynamic`) prüft, ob der Config-Ordner im Home existiert und wechselt automatisch den Modus.

### 🎁 3. nix-index-database (Zero-Wait File Search)
Normalerweise muss `nix-index` stundenlang die Filestruktur von nixpkgs indexieren.
- **Lösung:** `nix-index-database` von Mic92 liefert den fertigen Index wöchentlich via Flake-Input.
- **Nutzen:** Sofortige Suche nach Dateien in Paketen (`comma` Support).

### 🎁 4. import-tree (Dendritic Engine)
Vimjoyer nutzt ebenfalls `vic/import-tree`. Es bestätigt unseren Pfad: Ordnerstrukturen sollten automatisch importiert werden, um "Import-Listen-Chaos" zu vermeiden.

## 3. Strategische Empfehlung für mynixos
Wir sollten den **Wrapped-Tool Standard** für unsere SRE-Tools (nh, nix-diff) übernehmen und die **nix-index-database** in den Core (Layer 00) integrieren.

---
> [SOURCE]: https://github.com/vimjoyer/nixconf
