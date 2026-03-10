---
title: 💻 HomeDash: The CLI Command Center (Layer 00-core)
category: architecture/ui
status: [PROPOSED]
capabilities: [terminal-ui, bubble-tea-framework, real-time-stats, headless-dashboard]
sources: [r/selfhosted, HomeDash GitHub]
---

# 💻 HomeDash: Dein Dashboard im Terminal

In mynixos lehnen wir unnötige Web-UIs ab. HomeDash bietet eine hochperformante Übersicht deiner Dienste direkt in der SSH-Session.

## 🏛️ 1. Warum HomeDash?
- **Technologie:** In Go geschrieben (Efficiency Mandate). ✅
- **Framework:** Nutzt Bubble Tea für moderne, interaktive Terminal-UIs.
- **Headless-First:** Folgt strikt ADR-010. Kein Browser nötig.

## ⚙️ 2. Installation & Integration
Da HomeDash oft als Go-Binary verteilt wird, binden wir es direkt in unser SRE-User-Profil ein.

\`\`\`nix
# In modules/00-core/shell.nix
environment.systemPackages = with pkgs; [
  homedash
];
\`\`\`

## 📊 3. Features
- Anzeige der CPU/RAM Last (inkl. ZRAM Swap Status).
- Status-Check deiner Docker-Container oder systemd-Dienste.
- Netzwerk-Durchsatz in Echtzeit.

## 🚀 SRE-Vorteil
Ermöglicht einen schnellen System-Check bei der Anmeldung am Tower, ohne die Latenz eines Web-Dashboards wie Homepage oder Dashy.