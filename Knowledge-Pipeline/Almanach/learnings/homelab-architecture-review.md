---
title: "Homelab Architecture Review (v4.2)"
category: "learnings"
tags: [nixos, audit, security, architecture]
date: 2026-03-08
source: "raw/_duplikate/Gemini-NixOS Homelab Architecture Review.md"
status: "verified-substance"
---

# 🧠 LEARNING: ARCHITECTURE AUDIT & RISK ANALYSIS

Kritische Analyse der NixHome-Infrastruktur mit Fokus auf Skalierbarkeit und Hardening.

> **Verwandte Konzepte:** 
> - [SRE Audit NMS v2.3](sre-audit-v2.3.md)
> - [NixHome Architecture](../adr/nixhome-architecture.md)

## 🔍 BEFUNDE & RISIKO-MATRIX

### Struktur & Skalierbarkeit
**Problem:** Die Layer-Architektur (00-90) kann bei >100 Services zu Evaluierungs-Bottlenecks führen.
**Lösung:** Einsatz von `flake-parts`, um Definitionen und Instanziierungen sauber zu trennen.

### Sicherheit (SSH & Proxy)
**Problem:** Fehlende CIS-Vorgaben in der Standard-SSH-Config.
**Lösung:**
```nix
services.openssh.settings = {
  PermitRootLogin = "no";
  PasswordAuthentication = false;
  KexAlgorithms = [ "sntrup761x25519-sha512@openssh.com" ];
};
```

> [LIVE-ENRICHMENT]: Das Prädikat "Aviation-Grade" erfordert zudem die Deaktivierung von TCP-Forwarding (`AllowTcpForwarding = "no"`) und die Reduzierung der `MaxAuthTries` auf 3, um Brute-Force-Angriffe im Keim zu ersticken.

## 🛠️ DIE TOP-5 FIXES (PRIORISIERT)
1. **KRITISCH:** N8N Encryption Key aus Hardcode in SOPS verschieben.
2. **HOCH:** mTLS-Zertifikate für Caddy absichern (PKCS12 Passwort).
3. **HOCH:** Impermanence für `/data/persist` implementieren (Drift-Detection).
