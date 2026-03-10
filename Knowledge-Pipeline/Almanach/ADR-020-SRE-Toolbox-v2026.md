# [ADR-020]: SRE-Toolbox v2026 (Aviation-Grade)
# ID: [ADR-020] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Diese Entscheidung legt die Standard-Werkzeuge für die System-Administration und Fehlerbehebung (SRE) fest. Ziel ist es, jederzeit aussagekräftige Diagnosen über SSH durchführen zu können, ohne schwere Software-Stacks installieren zu müssen.

## 2. Technical Layer (Spezifikation)
Folgende Pakete werden als Kern-Toolbox in die `environment.systemPackages` der `00-core/shell.nix` aufgenommen:

| Kategorie | Tool | Nixpkgs-Pfad | Sprache |
|---|---|---|---|
| Network Discovery | RustScan | `pkgs.rustscan` | Rust |
| Path Analysis | mtr | `pkgs.mtr` | C |
| Traffic Analysis | Termshark | `pkgs.termshark` | Go |
| Bandbreite | bmon | `pkgs.bmon` | C |
| Security Audit | Lynis | `pkgs.lynis` | Shell |
| TLS/SSL Audit | testssl.sh | `pkgs.testssl` | Shell |
| Benchmarks | iPerf3 | `pkgs.iperf3` | C |
| Nix Workflow | nh | `pkgs.nh` | Rust |
| Nix Diff | nvd | `pkgs.nvd` | C |
| Nix Linting | statix | `pkgs.statix` | Rust |
| Nix Hygiene | deadnix | `pkgs.deadnix` | Rust |

## 3. Reasoning Layer (ADR)
- **Binary-Effizienz:** Bevorzugung von Rust/Go/C-Binaries gegenüber Python- oder Java-basierten Tools zur Minimierung des Laufzeit-Footprints auf dem Fujitsu Q958.
- **TUI-Kompetenz:** Alle gewählten Tools sind für die Arbeit im Terminal (SSH) optimiert und erfordern keine grafische Oberfläche.
- **Verworfene Alternativen:** Wireshark (zu schwer für Headless-Server), Nmap (ersetzt durch das schnellere RustScan für initiale Scans), iperf2 (veraltet).
- **Nix-Native Tools:** `nh` und `nvd` verbessern die operative Sichtbarkeit von Systemänderungen massiv.

---
> [SOURCE-NUGGET]: [NUGGET-SRE-001] & [NUGGET-NIX-AWESOME] aus mighty-awesome-nix.md
> [VALIDIERUNG]: Verifiziert gegen nixpkgs unstable am 10.03.2026.
