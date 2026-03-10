---
title: 📦 Nixpkgs Packaging Standard (Aviation-Grade Quality)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [package-creation, testing-standards, automated-updates, meta-excellence]
sources: [Nixpkgs Contributing Guide]
---

# 📦 Der mynixos Packaging Standard

Wir folgen strikt den offiziellen Nixpkgs-Richtlinien, um maximale Kompatibilität und Wartbarkeit zu garantieren.

## 🏛️ 1. Struktur (The by-name Law)
Eigene Pakete werden in \`mynixos/pkgs/by-name/\` abgelegt.
- **Pfad:** \`pkgs/by-name/${prefix}/${name}/package.nix\`
- **Vorteil:** Automatische Entdeckung durch Nix ohne manuelle Imports.

## 🛡️ 2. Validierung (passthru.tests)
Jedes Paket **muss** einen Test enthalten.
\`\`\`nix
passthru.tests = {
  version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "${meta.mainProgram} --version";
  };
};
\`\`\`

## ⚙️ 3. Meta-Attribute (The 7-Gate Quality)
- \`description\`: Kurz, prägnant, kein Punkt am Ende.
- \`license\`: Muss exakt dem Upstream entsprechen.
- \`mainProgram\`: Name der primären Binary.
- \`maintainers\`: Dein GitHub-Handle.

## 🔄 4. Automated Updates
Nutze \`passthru.updateScript = nix-update-script { };\`, um Paket-Updates zu automatisieren.