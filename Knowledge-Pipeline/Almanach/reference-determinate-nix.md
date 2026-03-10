# [REFERENCE]: Determinate Nix & Sovereign Ecosystem
# ID: [NUGGET-KNOWLEDGE-002] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & Zweck
Dieses Dokument fasst das Wissen über die Tools von Determinate Systems zusammen, die wir für unsere Souveränität nutzen. Wir setzen auf diese Standards, um die Kluft zwischen Nix-Expertise und Aviation-Grade Stabilität zu überbrücken.

## 2. Die Kern-Komponenten

### 🚀 Der Determinate Installer
- **Nutzen:** Ersetzt den Standard-Nix-Installer durch eine robustere Rust-Implementierung.
- **Souveränität:** Bietet bessere Deinstallations-Routinen und State-Management.

### 🛡️ Flake Checker
- **Zweck:** Automatische Prüfung von Flakes auf bekannte Schwachstellen und veraltete Inputs.
- **Integration:** Sollte Teil unserer SRE-Shell werden.

### 📦 FlakeHub & Caching
- **Konzept:** Ein Spiegel für Flakes (ähnlich unserer Forgejo-Idee in ADR-032).
- **Vorteil:** Schnellere Downloads durch optimierte Binär-Caches.

## 3. Strategische Entscheidung
Wir nutzen die *Ideen* von Determinate (Installer, Checker), bleiben aber bei unserem **ADR-032 Mandat**, alle Quellen physisch lokal in **Forgejo** zu spiegeln, um nicht von FlakeHub abhängig zu sein.

---
> [SOURCE]: Kompression aus det-*.md Rohdaten (Erzmine)
