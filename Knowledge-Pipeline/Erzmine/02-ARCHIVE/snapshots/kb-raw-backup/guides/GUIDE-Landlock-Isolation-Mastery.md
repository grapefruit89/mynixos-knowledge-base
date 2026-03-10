---
title: 🔒 Landlock Isolation: Next-Gen Sandboxing (Layer 90-policy)
category: architecture/security
status: [PROPOSED]
capabilities: [kernel-level-isolation, path-filtering, unprivileged-sandboxing]
sources: [r/NixOS, Linux Landlock Documentation]
---

# 🔒 Landlock: Das chirurgische Sandboxing

In mynixos evaluieren wir Landlock als Ergänzung oder Ersatz für nsjail. Es ermöglicht eine extrem feingranulare Zugriffskontrolle auf Dateisystem-Ebene direkt im Kernel.

## 🏛️ 1. Warum Landlock?
- **Native Power:** Es ist ein LSM (Linux Security Module) wie AppArmor, aber für einzelne Prozesse steuerbar.
- **Efficiency:** Verursacht fast keinen Performance-Overhead. ✅
- **Unprivileged:** Dienste können sich selbst einsperren, ohne Root-Rechte zu benötigen.

## ⚙️ 2. Architektur-Integration
Wir nutzen Landlock-Wrapper für Dienste, die nur auf spezifische Verzeichnisse zugreifen dürfen (z.B. n8n auf seine Workflows).

### SRE-Blueprint:
\`\`\`nix
# Beispiel für einen Landlock-härtenden Wrapper
mynixosLib.mkLandlockedService {
  name = "worker-script";
  allowedPaths = [ "/persist/data" "/tmp" ];
  # Alles andere im System ist für diesen Prozess physisch unsichtbar.
}
\`\`\`

## 🛡️ 3. SRE-Vorteil
Landlock ist der ultimative Schutz gegen "Path Traversal" Angriffe. Selbst wenn ein Dienst gehackt wird, kann er keine SSH-Keys oder Konfigurationen lesen, die nicht explizit freigegeben wurden. ✅

## 🚀 SRE-Anwendung
Diese Technologie wird primär in **Layer 30 (Automation)** eingesetzt, um Scripte von n8n oder eigene Python-Tools (Kapitel 62) maximal zu isolieren.