---
title: 🌐 FlakeHub & Dependency Vetting
category: architecture/policy
status: [ACTIVE-SSoT]
capabilities: [semantic-versioning, secure-inputs, audit-tooling]
sources: [https://docs.determinate.systems/flakehub]
---

# 🌐 FlakeHub: Vertrauenswürdige Inputs

FlakeHub bringt Ordnung in das Chaos der Git-basierten Flake-Inputs.

## 🏛️ SemVer Strategie
In mynixos nutzen wir SemVer für kritische Inputs:
\`\`\`nix
inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
\`\`\`
- **Vorteil:** Wir erhalten automatisch Sicherheits-Updates (Bugfixes), ohne dass Breaking Changes unser System unvorhergesehen zerstören.

## 🔍 Audit mit der FH-CLI
Das Tool \`fh\` erlaubt uns das Auditing von Abhängigkeiten:
- \`fh list\`
- \`fh search\`