---
title: ADR-004: Media Engine & VPN Isolation Standard
status: [ACCEPTED]
category: architecture/decision
capabilities: [vpn-namespaces, hardware-transcoding, dendritic-purity]
sources: [nixarr, nixflix, Internal SRE Audit]
---

# 🏛️ ADR-004: Die mynixos Media Engine

## Kontext
Wir implementieren den Medien-Stack (Layer 40). Wir wollen die Sicherheit von `nixarr` und die Performance von `nixflix`, aber ohne deren architektonische Altlasten.

## Entscheidung
Wir implementieren eine "Hybrid-Engine":
1.  **VPN-Isolation:** Wir nutzen das Namespace-Pattern von `nixarr` (Native NixOS netns).
2.  **Hardware:** Wir nutzen die QuickSync-Optimierungen von `nixflix` (iHD Driver).
3.  **Struktur:** Wir nutzen das **mynixos v8.0 Flat-Dendritic Pattern**.

## Was wir besser machen (Aviation-Grade Improvements)
- **Caddy Injektion:** Jeder Medien-Dienst injiziert seinen Ingress selbst (Dendritic Synthesis).
- **Sops-First:** Alle API-Keys (Sonarr, Radarr) werden zwingend via Sops verschlüsselt.
- **Binary-Only:** Wo möglich, nutzen wir Go/Rust-Helfer (z.B. Recyclarr).

## Konsequenz
Der Medien-Stack wird zum sichersten und effizientesten Teil des Systems. Kein Dienst kann am VPN vorbei kommunizieren.