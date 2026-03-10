# [GUIDE]: Nix Quality & SRE Tooling (Awesome-Nix Extract)
# ID: [NUGGET-NIX-AWESOME] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & Prinzipien
Dieser Guide destilliert die wertvollsten Werkzeuge aus dem `nix-community/awesome-nix` Repository, die streng unserem "Aviation-Grade" (Rust/Go/C, Single-Binary, hohe Effizienz) und "Dendritic" Paradigma entsprechen. Sie dienen der Code-Qualität, dem Deployment und der System-Sichtbarkeit.

## 2. Die Tool-Matrix

### 🛠️ Code-Qualität & Refactoring (Hygiene)
- **`statix` (Rust):** Linter zur Erkennung und Behebung von Anti-Patterns in Nix-Code. Verhindert technische Schulden.
- **`deadnix` (Rust):** Scannt Nix-Dateien auf toten (ungenutzten) Code. Essenziell für die Sauberkeit der Werkstatt.
- **`alejandra` (Rust):** Kompromissloser, rasend schneller Nix-Code Formatter. Zwingt den Code in eine einheitliche, gut lesbare Form.

### 🔍 Sichtbarkeit & Diffing (Observability)
- **`nvd` (C):** Differenziert Paketversionen zwischen zwei NixOS-Generationen. Unverzichtbar vor/nach einem `nixos-rebuild`, um genau zu sehen, was aktualisiert wurde.
- **`nix-diff` (Haskell):** Erklärt im Detail, *warum* sich zwei Derivations unterscheiden.
- **`nix-tree` (Haskell):** Interaktiver TUI-Browser für den Dependency-Graphen. Hilft beim Aufspüren von "Bloat" im System.
- **`nix-output-monitor` (`nom`):** Parst die Build-Logs von Nix und visualisiert sie anschaulich (inklusive Graphen zur Build-Zeit).

### 🚀 Workflow & Deployment (SRE Ops)
- **`nh` (Nix Helper - Rust):** Ein moderner Wrapper um die Nix-CLI. Bietet sauberes Output-Handling (via `nom`) und integriertes, sicheres Garbage-Collection-Management (`nh clean`).
- **`nixos-anywhere`:** Das Standardwerkzeug, um NixOS remote über SSH auf leere Zielsysteme zu deployen.
- **`Colmena` (Rust):** Ein staatenloses Deployment-Tool für NixOS, ideal falls wir später weitere Nodes (z.B. Raspberry Pis) ins Cluster aufnehmen.

## 3. Integration in die Werkstatt
Einige dieser Tools wurden bereits in die `shell.nix` (Layer 00-core) aufgenommen (siehe ADR-020). 

**Best-Practice SRE Workflow:**
1. Code-Anpassung in der Werkstatt.
2. `statix check .` und `deadnix .` ausführen.
3. `alejandra .` für die Formatierung.
4. `nh os test` (anstelle von `nixos-rebuild test`), um den Build mit `nom`-Visualisierung zu überwachen.
5. Nach dem Build: `nvd diff /run/current-system result`, um die Änderungen zu auditieren.

---
> [SOURCE]: https://github.com/nix-community/awesome-nix
> [LINKED-ADR]: ADR-020-SRE-Toolbox-v2026.md
