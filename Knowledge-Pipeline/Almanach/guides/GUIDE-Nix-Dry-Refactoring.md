---
title: ✂️ Nix DRY Refactoring (Eliminating Boilerplate)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [code-reduction, custom-lib-extensions, standard-hardening-wrappers]
sources: [r/Nix, numtide/srvos, NixOS Library Docs]
---

# ✂️ DRY Refactoring: Schluss mit der Boilerplate-Hölle

In mynixos folgen wir dem DRY-Prinzip (Don't Repeat Yourself). Wir ersetzen redundante Modul-Strukturen durch zentrale Hilfsfunktionen.

## 🏛️ 1. Das Problem (Boilerplate-Exhaustion)
Bisher brauchte jeder Dendrit (Modul) ~20 Zeilen Standard-Code für Metadaten und \`mkEnableOption\`. Das erhöht die Fehlerquote und erschwert globale Änderungen.

## ⚙️ 2. Die Aviation-Grade Lösung (Custom Lib)
Wir definieren in der \`flake.nix\` eine \`mynixosLib\`, die Standard-Wrappers bereitstellt.

### Beispiel: Der hocheffiziente Service-Wrapper
Anstatt jedes Mal das GPU-Hardening (Kapitel 65) neu zu schreiben, nutzen wir:
\`\`\`nix
mynixosLib.mkHardenedService {
  name = "jellyfin";
  gpuAccess = true;
  cpuLimit = "50%";
  # ... der Rest wird automatisch generiert
}
\`\`\`

## 🛡️ 3. SRE-Vorteil
- **Wartbarkeit:** Globale Sicherheits-Updates (z.B. neue systemd-Hardening Flags) müssen nur an **einer Stelle** in der \`lib\` geändert werden und wirken sofort auf alle 40+ Dienste. ✅
- **Klarheit:** Deine Modul-Dateien enthalten nur noch die **Logik**, nicht die Infrastruktur.

## 🚀 SRE-Anwendung
Wir migrieren alle Layer (00-90) sukzessive auf dieses Wrapper-Modell. Dies ist die Voraussetzung für die "God-Mode" Stabilität v8.5.