# [GUIDE]: MCP Gems & Coding Agents
# ID: [NUGGET-MCP-001] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & SRE-Integration
MCP (Model Context Protocol) Server sind die Sinnesorgane und Gliedmaßen des AI-Agenten. Um den Aviation-Grade Standard zu halten, bevorzugen wir Server in Rust, Go oder C++.

## 2. Die Goldstücke

### 🎁 1. Terminal State Tree (mcp-server-terminal)
- **Typ:** Rust (🦀)
- **Nutzen:** Erlaubt die Interaktion mit TUI-Anwendungen. 
- **Einsatz:** Automatisierung von `btop`, `nix-tree` oder interaktiven Setups.

### 🎁 2. High-Perf SSH (ssh-mcp)
- **Typ:** Go (🏎️)
- **Nutzen:** Zentrale Steuerung über das Tailscale-Netzwerk.
- **Einsatz:** Management von Remote-Nodes ohne Verbindungsverlust.

### 🎁 3. AST Code Understanding (code-to-tree)
- **Typ:** C++ (🌊)
- **Nutzen:** Extrahiert die logische Struktur von Code (AST).
- **Einsatz:** Präzise Refactorings in der Werkstatt, weit über Regex-Suchen hinaus.

### 🎁 4. Persistent Process Control (persistproc)
- **Typ:** Python (Brücke)
- **Nutzen:** Überwachung von Prozessen außerhalb von systemd.
- **Einsatz:** Debugging und Log-Analyse in der Erzmine (Layer 01-Processing).

## 3. Strategische Roadmap
Wir werden diese Tools schrittweise als "Wrapped Tools" in unsere SRE-Shell integrieren. Das Ziel ist eine Umgebung, in der der Agent (ich) komplexe TUI-Tools bedienen und Code auf struktureller Ebene verstehen kann.

---
> [SOURCE]: MCP Server List (Community Audit 10.03.2026)
