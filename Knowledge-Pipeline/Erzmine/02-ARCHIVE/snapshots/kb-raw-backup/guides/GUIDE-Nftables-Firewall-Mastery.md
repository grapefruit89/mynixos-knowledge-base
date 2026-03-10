---
title: 🛡️ Nftables Firewall Mastery (Layer 00-core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [atomic-rulesets, build-time-validation, fail2ban-integration, nat-nft]
sources: [nixpkgs/nixos/modules/services/networking/nftables.nix, fail2ban.nix]
---

# 🛡️ Nftables: Die Aviation-Grade Firewall

In mynixos ist nftables das einzige erlaubte Firewall-Backend. Es ersetzt das veraltete iptables vollständig.

## 🏛️ 1. Die SRE-Konfiguration (Layer 00-core)
Wir nutzen die Build-Zeit-Validierung, um uns niemals auszusperren.
- **Dienst:**
\`\`\`nix
networking.nftables = {
  enable = true;
  checkRuleset = true; # Zwingend: Validierung vor Aktivierung
};
\`\`\`

## 🛡️ 2. Fail2ban Integration (Layer 30-services)
Fail2ban wird angewiesen, nativ mit nftables zu kommunizieren.
\`\`\`nix
services.fail2ban = {
  enable = true;
  banaction = "nftables-multiport";
};
\`\`\`

## 🌐 3. Deklaratives NAT & Port-Forwarding
Wir deklarieren Regeln nicht über Scripte, sondern über das strukturierte Ruleset-File.
- **Pattern:** Nutzung von \`networking.nftables.rulesetFile\`, um komplexe Tabellen (Filter, Nat, Mangle) sauber zu trennen.

## 🚀 SRE-Vorteil
- **Atomic Reload:** nftables lädt das gesamte Regelwerk atomar. Es gibt keinen Zustand, in dem die Firewall "halb offen" ist.
- **Performance:** Deutlich geringere CPU-Last bei hohen Paketraten im Vergleich zu iptables.