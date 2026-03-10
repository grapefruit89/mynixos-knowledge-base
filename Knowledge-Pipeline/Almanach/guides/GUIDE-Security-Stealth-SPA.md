---
title: 🕵️ Security Stealth SPA (Single Packet Authorization)
category: architecture/security
status: [ACTIVE-SSoT]
capabilities: [stealth-firewall, encrypted-knocking, anti-replay-protection]
sources: [nixpkgs/pkgs/tools/networking/fwknop, CipherDyne Docs]
---

# 🕵️ SPA: Die unsichtbare Firewall

In mynixos nutzen wir SPA (Single Packet Authorization), um unsere administrativen Ports (SSH) vor dem Internet zu verstecken.

## 🏛️ 1. Warum SPA statt Port Knocking?
Klassisches Klopfen ist unsicher (Replay-Attacken). SPA nutzt:
- **Verschlüsselung:** Das Klopf-Paket ist AES-verschlüsselt.
- **Signatur:** Nur autorisierte Keys können den Port öffnen.
- **Non-Standard:** Der Wächter hört passiv auf dem Netzwerk-Stack, ohne einen offenen Port zu zeigen.

## ⚙️ 2. Workflow für den SRE (Tower-Zugriff)
Um dich einzuloggen, nutzt du den automatisierten Trigger:

### Am Laptop (Linux/Mac):
\`\`\`bash
# Einmalige Konfiguration in .bashrc
alias nix-ssh='fwknop -n mynixos-tower && ssh nix'
\`\`\`
- **Ergebnis:** Ein Befehl öffnet die Firewall und verbindet dich. ✅

### Am Smartphone (Android/iOS):
- App: **fwknop2**. Ein Klick auf das Widget schickt den Schlüssel, danach öffnet sich deine SSH-App.

## 🛠️ 3. NixOS Implementierung
Wir nutzen das \`fwknop\` Modul in Layer 00-core.
- **Integration:** \`fwknopd\` kommuniziert direkt mit \`nftables\` (Kapitel 56), um dynamische Regeln für deine IP einzufügen.

## 🚀 SRE-Vorteil
Selbst wenn eine Sicherheitslücke in OpenSSH gefunden wird, ist dein Tower sicher, da der Angreifer den SSH-Dienst physisch nicht erreichen kann.