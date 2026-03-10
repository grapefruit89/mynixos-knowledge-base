---
title: ADR-014: Systemic Governance & Purity Mandate
status: [ACCEPTED]
category: architecture/decision
capabilities: [evaluation-performance, dependency-integrity, security-purity]
sources: [Nixpkgs Maintainer Guide, Manifest v7.1]
---

# 🏛️ ADR-014: Systemic Governance

Dieses ADR definiert die Regeln für die langfristige Stabilität und Sicherheit von mynixos.

## 🚫 1. IFD-Verbot (No Import-From-Derivation)
Um die Evaluations-Performance des Flakes zu garantieren, ist IFD im gesamten \`mynixos/\` Baum untersagt.
- **Regel:** Generierte Dateien (z.B. API-Listen) müssen committed werden, anstatt sie während der Evaluation zu bauen.

## 🛠️ 2. Fix-at-Source (Anti-Override Policy)
Wir vermeiden \`overrideAttrs\` oder \`overridePythonAttrs\` innerhalb der eigenen Module.
- **Regel:** Wenn ein Paket angepasst werden muss, geschieht dies durch eine saubere Funktions-Abstraktion oder einen direkten Patch im Paket-Dendriten.
- **Ziel:** Ein transparenter, flacher Abhängigkeitsgraph.

## 🛡️ 3. Security-Source-Purity
Sicherheitskritische Komponenten (PAM, SUID, Auth-Dienste) dürfen niemals als binäre Blobs eingebunden werden.
- **Regel:** Bau aus dem verifizierten Quellcode ist zwingend.
- **Audit:** Jede externe Quelle muss eine stabile Checksumme (SHA-256) haben.

## Begründung
Diese Regeln verhindern die schleichende Erosion der Systemqualität ("Software Rot") und garantieren, dass der Tower auch nach 5 Jahren noch wartbar bleibt.