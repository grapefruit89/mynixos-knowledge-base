---
title: 🕵️ DetSys Advanced Tooling & Security (SRE Tor 6)
category: architecture/policy
status: [ACTIVE-SSoT]
capabilities: [supply-chain-security, lockfile-auditing, private-flakes]
sources: [https://github.com/DeterminateSystems/flake-checker]
---

# 🕵️ Advanced DetSys: Supply Chain Security

Determinate Systems bietet Werkzeuge, um die Integrität deiner Flake-Inputs (SRE Tor 6) automatisiert zu überwachen.

## 🔍 1. Flake Checker (Security Auditor)
Der \`flake-checker\` ist unser primäres Tool für den Audit der \`flake.lock\`.
- **Was wird geprüft?**
    - Bekannte Sicherheitslücken (CVEs) in den genutzten Nixpkgs-Versionen.
    - Verwendung von "unstable" vs. "stable" Branches.
    - Alter der Lockfile (Vermeidung von "Stale Inputs").
- **Integration:** Läuft als regelmäßiger systemd-Timer auf dem Tower.

## 🔐 2. Private Flakes & Secrets
Determinate Systems nutzt FlakeHub als sicheres Repository für private Flakes.
- **Workflow:** Authentifizierung via Token, die sicher in der \`devShell\` via Sops-Nix verwaltet werden.
- **Vorteil:** Ermöglicht das Teilen von privaten Modulen zwischen verschiedenen Projekten, ohne Secrets in den Sourcecode zu schreiben.

## 🚀 3. Determinate Nix (Optimierte Distribution)
Dies ist eine vorkonfigurierte Nix-Distribution, die:
- **Telemetry & Metrics:** Eingebautes SRE-Monitoring bietet.
- **Warmed Caches:** Den Zugriff auf vorkompilierte Binaries beschleunigt.
- **Lazy Evaluation:** Den Speicherverbrauch bei der Evaluation massiv senkt.