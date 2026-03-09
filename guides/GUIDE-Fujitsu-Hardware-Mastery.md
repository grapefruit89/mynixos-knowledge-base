---
title: 🖥️ Fujitsu Q958 Hardware-Optimierung (Layer 80-monitoring)
category: architecture/hardware
status: [ACTIVE-SSoT]
capabilities: [bios-tuning, power-efficiency, hardware-acceleration, fujitsu-support]
sources: [https://secretmine.de/ (Hardware Category), Fujitsu Technical Docs]
---

# 🖥️ Fujitsu Q958: Die Aviation-Grade Hardware-Basis

Dein Tower (i3-9100, 16GB RAM) ist eine hocheffiziente Maschine. Wir optimieren die physische Schicht für maximalen Durchsatz bei minimalem Verbrauch.

## 🏛️ BIOS-Tuning (SRE Standard)
1.  **C-States:** Aktivierung aller Power-Saving C-States (C10), um den Idle-Verbrauch auf < 10W zu drücken.
2.  **Intel QuickSync:** Sicherstellen, dass die iGPU (UHD 630) permanent aktiviert ist (Primary Display: IGD).
3.  **Auto-Power-On:** Aktivierung nach Stromausfall für ununterbrochenen SRE-Betrieb.

## ⚡ Power Management in NixOS
Wir nutzen das \`services.tlp\` oder \`services.power-profiles-daemon\` Modul, um die Fujitsu-Hardware zu steuern.
\`\`\`nix
services.tlp = {
  enable = true;
  settings = {
    CPU_SCALING_GOVERNOR_ON_AC = \"powersave\";
    CPU_ENERGY_PERF_POLICY_ON_AC = \"balance_power\";
  };
};
\`\`\`

## 🛡️ SRE-Integrität (Hardware-Watchdog)
Wir nutzen den integrierten Intel-Watchdog (\`iTCO_wdt\`), um das System bei Kernel-Panics automatisch neu zu starten.
