# [NUGGET-SEC-001]: Aviation-Grade CLI-Tools
# Status: ACCEPTED | Stand: 10.03.2026

## 1. Context
Ein moderner SRE-Workflow benötigt Tools, die schnell, sicher und deklarativ integrierbar sind. Wir bevorzugen Go/Rust Binaries gegenüber Python/Perl-Skripten (Single-Binary-Mandat).

## 2. Die Auswahl (The Best-of)

### 🚀 Network Discovery (The Fast Path)
- **RustScan (Rust):** Port-Scanning in Millisekunden. Perfekt zur Validierung der nftables-Regeln.
- **nmap:** Der Klassiker für tiefgehende Audits.

### 🦈 Traffic Analysis (TUI-Native)
- **Termshark (Go):** Die Go-native TUI für tshark. Unverzichtbar für Debugging ohne GUI.
- **ngrep:** Grep für den Netzwerk-Stack.

### 🛡️ Security Audit & SSL
- **Lynis:** Das Schweizer Taschenmesser für System-Audits.
- **testssl.sh:** Prüft deine Caddy-HTTPS Endpunkte auf Schwachstellen.

### 🏎️ Monitoring & Performance
- **btop (C++):** Dein Dashboard für Ressourcen (schon in shell.nix).
- **iPerf3:** Zur Messung des LAN-Durchsatzes (Fujitsu Q958 Limits).

## 3. Implementation (Werkstatt)
Diese Tools sollten in die `environment.systemPackages` deiner `shell.nix` aufgenommen werden.

---
> [SOURCE]: https://github.com/trimstray/the-book-of-secret-knowledge
> [CONVERSION]: Veredelt aus Erzmine/03-RESOURCES/external-sources/MANIFEST_NEW_SOURCES.md
