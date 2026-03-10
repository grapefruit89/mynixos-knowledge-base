---
title: 🛡️ Enterprise Governance & Secure Packages (SRE Tor 7)
category: architecture/policy
status: [ACTIVE-SSoT]
capabilities: [cve-remediation, sbom-provenance, automated-gc]
sources: [https://docs.determinate.systems/introduction]
---

# 🛡️ Enterprise Governance: Sicherheit & Nachweisbarkeit

Für mynixos nutzen wir die Governance-Werkzeuge von Determinate Systems, um eine industrielle Nachweisbarkeit (Provenance) zu erreichen.

## 📦 1. Determinate Secure Packages
Wir nutzen den gesicherten Downstream von Nixpkgs.
- **SLA-Fixes:** Schnelle Behebung von Sicherheitslücken (CVEs) durch das DetSys-Team.
- **Auditable:** Jedes Paket ist signiert und verifiziert.

## 🔍 2. SBOMs (Software Bill of Materials)
Jeder Build in mynixos generiert eine SBOM.
- **Zweck:** Eine vollständige Liste aller Bibliotheken und Abhängigkeiten, die in einem Dienst (z.B. Caddy) enthalten sind.
- **Traceability:** Erfüllt SRE Tor 7 auf höchstem Niveau.

## ⚙️ 3. Determinate Nixd (Automation)
Der eingebaute Daemon übernimmt administrative Aufgaben:
- **Automated GC:** Hält den Speicherplatz auf dem Tower sauber.
- **FlakeHub Link:** Regelt die Authentifizierung für private und verifizierte Flakes im Hintergrund.

## 🚀 SRE-Anwendung
In \`modules/90-policy/governance.nix\` erzwingen wir die Nutzung signierter Pakete und aktivieren die automatische Garbage Collection via Nixd.