# [GUIDE]: Aviation-Grade SRE Toolbox
# ID: [NUGGET-SRE-001] | Status: DESIGN-COMPLETE | Stand: 10.03.2026

## 1. Vision & Prinzipien
Diese Toolbox enthält die "scharfen Waffen" für Netzwerk-Audit, Security-Checks und Performance-Messung. Jedes Tool wurde nach dem **Binary-Effizienz-Mandat** ausgewählt (Go/Rust/C vor Python).

## 2. Die Waffenkammer (Tool-Spezifikation)

### 🚀 Aufklärung (Network Discovery)
- **RustScan (Rust):** `pkgs.rustscan`
  - *Zweck:* Port-Scanning in Lichtgeschwindigkeit.
  - *Einsatz:* `rustscan -a 192.168.2.0/24 --ulimit 5000`
- **mtr (C):** `pkgs.mtr`
  - *Zweck:* Kombiniert Ping und Traceroute.
  - *Einsatz:* Diagnose von Tailscale-Routing-Problemen.

### 🦈 Analyse (Traffic & Deep Packet Inspection)
- **Termshark (Go):** `pkgs.termshark`
  - *Zweck:* TUI für Wireshark. Unverzichtbar für verschlüsselte Header-Analysen.
- **bmon (C):** `pkgs.bmon`
  - *Zweck:* Live-Bandbreiten-Monitoring im TTY.

### 🛡️ Audit (Security & Hardening)
- **Lynis (Shell):** `pkgs.lynis`
  - *Zweck:* System-Hardening Audit.
  - *Einsatz:* `lynis audit system` (monatlicher Check empfohlen).
- **testssl.sh (Shell):** `pkgs.testssl`
  - *Zweck:* Testet Caddy-TLS Endpunkte auf Schwachstellen.
  - *Einsatz:* `testssl https://nix.m7c5.de`

### 🏎️ Performance (Benchmarks)
- **iPerf3 (C):** `pkgs.iperf3`
  - *Zweck:* Misst den LAN-Durchsatz zwischen Server und Clients.

## 3. Zukünftiger Guss (Werkstatt-Integration)
Wenn das Wissen in die Werkstatt gegossen wird, erfolgt dies über die `00-core/shell.nix`:
```nix
environment.systemPackages = with pkgs; [
  rustscan termshark lynis testssl iperf3 mtr bmon
];
```

## 4. Reasoning (Warum diese Auswahl?)
- **Minimaler Footprint:** Keine schweren Laufzeitumgebungen nötig.
- **NixOS Native:** Alle Tools sind als stabile Binaries in `nixpkgs` verfügbar.
- **TUI-Fokus:** Volle Bedienbarkeit über SSH (kein X11/GUI nötig).

---
> [SOURCE]: https://github.com/trimstray/the-book-of-secret-knowledge
> [CONVERSION]: Veredelt aus Erzmine/03-RESOURCES/external-sources/MANIFEST_NEW_SOURCES.md
