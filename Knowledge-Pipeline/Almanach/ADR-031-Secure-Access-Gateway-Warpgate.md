# [ADR-031]: Secure Access Gateway (Warpgate)
# ID: [ADR-031] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir führen Warpgate als zentrales Eingangstor (Bastion) für administrative Aufgaben ein. Dies ermöglicht uns sicheren Zugriff auf SSH, Datenbanken und Web-UIs mit automatischer Sitzungsaufzeichnung und Passkey-SSO.

## 2. Technical Layer (Spezifikation)
- **Target:** MyNixOS Layer 10 (Gateway).
- **Tool:** `pkgs.warpgate` (Safe Rust Implementation).
- **Protokolle:** SSH, HTTPS, MySQL, PostgreSQL.
- **Identity:** OIDC-Anbindung an Pocket-ID (ADR-001).
- **Observability:** Full Session Recording (Aviation-Grade Audit).

## 3. Reasoning Layer (ADR)
- **Warum Warpgate?** Es ist wesentlich schlanker als "Teleport" und nutzt reines Rust. Es erfordert keine Client-Software.
- **Sicherheits-Boost:** Ermöglicht das Schließen nativer SSH-Ports. 2FA wird zur Pflicht für Systemzugriffe.
- **Wissen:** Jede Änderung am System wird aufgezeichnet – perfekt für die Dokumentation im Almanach.

---
> [SOURCE]: https://github.com/warp-tech/warpgate
