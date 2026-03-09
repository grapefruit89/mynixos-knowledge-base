---
title: 🛡️ Aviation-Grade Hardening (srvos Pattern)
category: architecture/security
status: [ACTIVE-SSoT]
capabilities: [process-isolation, systemd-sandboxing, gpu-binding, srvos-standard]
sources: [numtide/srvos, systemd.exec(5)]
---

# 🛡️ Hardening: Der srvos-Standard

In mynixos nutzen wir das **srvos Pattern** (Numtide), um Dienste maximal zu isolieren, ohne die Hardware-Beschleunigung zu verlieren.

## 🏛️ 1. Das GPU-Paradoxon gelöst
Bisher bedeutete GPU-Zugriff oft den Verzicht auf \`PrivateDevices\`. Wir nutzen jetzt **BindPaths**.
- **Konzept:** Wir setzen \`PrivateDevices = true\`, binden aber den Render-Node explizit wieder in den Sandbox-Namespace ein.
- **Vorteil:** Der Dienst sieht die GPU, aber keine anderen physischen Geräte des Hosts. ✅

## ⚙️ 2. Der Hardening-Blueprint
Jeder Dendrit folgt diesem Sicherheits-Standard in der \`serviceConfig\`:
\`\`\`nix
NoNewPrivileges = true;
ProtectSystem = "strict";
ProtectHome = true;
PrivateTmp = true;
PrivateDevices = true;
BindPaths = [ "/dev/dri/renderD128" ]; # Nur wenn GPU nötig
CapabilityBoundingSet = [ "" ];
\`\`\`

## 🚀 SRE-Vorteil
Dieser Standard senkt die Angriffsfläche drastisch. Ein kompromittierter Dienst kann weder das Dateisystem modifizieren noch andere Hardware-Komponenten scannen.