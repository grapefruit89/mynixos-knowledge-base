---
title: 📡 Stable Network Interface Names (MAC Binding)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [network-stability, hardware-binding, predictable-interface-names]
sources: [r/NixOS, systemd.link Documentation]
---

# 📡 Netzwerk-Stabilität: MAC-basierte Namen

In mynixos akzeptieren wir keine zufälligen Schnittstellennamen. Wir binden den Namen der Netzwerkschnittstelle fest an die physische MAC-Adresse der Intel-Hardware.

## 🏛️ 1. Das Problem
Standardmäßig nutzt NixOS/systemd "Predictable Interface Names" (z.B. enp2s0). Diese können sich jedoch bei BIOS-Updates oder Kernel-Wechseln ändern, was deine Firewall-Regeln (Kapitel 56) unbrauchbar macht.

## ⚙️ 2. Die Aviation-Grade Lösung (systemd.link)
Wir erzwingen den Namen \`primary0\` für die Haupt-NIC des Towers.

Hier ist das Muster für deinen Dendriten (\`modules/00-core/network-harden.nix\`):

\`\`\`nix
systemd.network.links."10-primary0" = {
  matchConfig.MACAddress = "xx:xx:xx:xx:xx:xx"; # Deine Fuji Q958 MAC
  linkConfig.Name = "primary0";
};
\`\`\`

## 🛡️ 3. SRE-Vorteil
- **Vorhersehbarkeit:** Deine Firewall und dein Caddy-Bypass (v8.5) beziehen sich immer auf \`primary0\`. ✅
- **Resilienz:** Selbst ein komplettes Hardware-Upgrade des Mainboards erfordert nur die Änderung einer einzigen Zeile im Code.

## 🚀 SRE-Anwendung
Der Name \`primary0\` wird systemweit als Standard für alle Netzwerk-Policies verwendet.