---
title: "Strategy: Determinate Systems Deep-Dive (Phase 3 - Recovery & Security)"
category: "learnings"
tags: [nix, recovery, boot, security, caching, sre]
id: "NIXH-STRAT-008"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["Determinate Systems GitHub Org (bootspec, netboot, cache)"]
---

# Strategy: Determinate Systems Deep-Dive (Phase 3)

## 1. User Layer (KISS)
Dieses Dokument beschreibt dein Sicherheitsnetz für den absoluten Ernstfall. Wir nutzen die Technik von Determinate Systems, um sicherzustellen, dass dein Server auch dann startet, wenn die Festplatte kaputt ist. Zudem lernen wir, wie der Server beim Starten genau anzeigt, wer er ist und was er tut, und wie wir Updates durch blitzschnelles Zwischenspeichern (Caching) beschleunigen.

## 2. Technical Layer (Aviation-Grade)

### Boot-Introspektion via Bootspec (RFC-0125)
*   **Konzept:** Jede System-Generation exportiert eine boot.json.
*   **Nutzen:** Erlaubt es, Identitäts-Metadaten (z.B. Git-Commit-Hash oder SRE-Status) direkt in den Bootloader zu injizieren.
*   **Vorteil:** Erhöhte Transparenz beim manuellen Rollback im Boot-Menü.

### High-Speed Recovery via Netboot
*   **Technik:** Nutzung von nix-netboot-serve Patterns für flüchtige Rettungssysteme.
*   **Workflow:** Der Q958 kann bei einem Totalausfall der System-Partition ein minimales NixOS-Image via HTTP laden (10s Cycle Time).
*   **Anker:** Integration des Netboot-Servers auf dem Master-Identity-Stick.

### Optimiertes Caching (Magic Cache Patterns)
*   **Strategie:** Einführung eines lokalen "Warm-Cache" für Binärpakete.
*   **Umsetzung:** Synchronisation von häufig genutzten Kern-Paketen (Caddy, Postgres) auf Tier B (SSD), um Abhängigkeiten vom Internet während der Stage-1 Boot-Phase zu minimieren.

## 3. Reasoning Layer (History)

### [ADR-080] Adoption of Bootspec for Hardware Attestation
*   **Status:** In Evaluation (März 2026).
*   **Kontext:** Aktuell ist das System beim Booten eine "Black Box" bis die initrd-SSH Verbindung steht.
*   **Entscheidung:** Vorbereitung der Module auf Bootspec-Konformität.
*   **Vorteil:** Ermöglicht zukünftige Hardware-Attestierung (TPM-Messung des Boot-Zustands) basierend auf dem RFC-0125 Standard.

---
**Community-Abgleich:** Synchronisiert mit den neuesten RFC-Implementierungen der NixOS Community und Determinate Systems.
