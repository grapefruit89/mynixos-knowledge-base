---
title: "Strategy: Automated Security Audits with Flake-Checker"
category: "learnings"
tags: [security, audit, supply-chain, flakes, determinate-systems]
id: "NIXH-STRAT-005"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["https://github.com/DeterminateSystems/flake-checker"]
---

# Strategy: Automated Security Audits (flake-checker)

## 1. User Layer (KISS)
Der „flake-checker“ ist der Sicherheitsinspektor für dein System. Er prüft automatisch, ob die Bausteine deines Servers (nixpkgs) noch aktuell sind, ob sie von den offiziellen Maintainern stammen und ob es sicherheitskritische Verzögerungen gibt. Das hilft dir, Supply-Chain-Angriffe (wie gefälschte Pakete) zu erkennen, bevor sie auf deinem Server landen.

## 2. Technical Layer (Aviation-Grade)

### Kern-Prüfungen (Supply-Chain Health)
*   **Staleness Detection:** Prüft, ob die  älter als 30 Tage ist (Default).
*   **Provenance Verification:** Stellt sicher, dass nixpkgs Inputs ausschließlich von der offiziellen  GitHub-Organisation stammen.
*   **Branch Validity:** Verifiziert, dass eine unterstützte Release-Line (z.B.  oder ) genutzt wird.

### Lokale Integration (SRE Workflow)
Für ein "Aviation-Grade" Homelab wird der Checker in Layer 90 (Policy) verankert:
1.  **Pre-Flight Check:** Einbindung in die lokale CI vor jedem Deployment.
2.  **Systemd Timer:** Täglicher Scan mit Logging ins Journal.

### Implementierung (Nix-Snippet)


## 3. Reasoning Layer (History)

### [ADR-076] Automated Supply-Chain Auditing
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Manuelle Prüfungen von Updates in flake.lock sind fehleranfällig und werden oft ignoriert.
*   **Entscheidung:** Integration von flake-checker als zwingender Policy-Baustein.
*   **Vorteile:** Proaktive Warnung bei "stalen" Inputs. Garantie, dass das System immer auf einem sicheren, authentischen Fundament basiert.

---
**Community-Abgleich:** Der flake-checker ist der de-facto Standard für Integritäts-Checks im Flake-Ökosystem.
