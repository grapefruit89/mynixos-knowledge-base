---
title: ADR-011: On-Demand Service Orchestration (Socket Activation)
status: [PROPOSED]
category: architecture/decision
capabilities: [resource-efficiency, systemd-socket-activation, wake-on-request]
sources: [Systemd Documentation, NixOS Manual, Caddy Documentation]
---

# 🏛️ ADR-011: On-Demand Services (Der "Sleepy Server" Standard)

## Kontext
Wir betreiben ~30 Dienste auf einem Home-Server. Viele davon (z.B. Paperless, Readarr) werden nur selten aktiv genutzt.

## Entscheidung
Wir implementieren, wo technisch möglich, das **Socket-Activation Pattern**:
1.  **Passive Mode:** Dienste verbrauchen im Idle 0% Ressourcen.
2.  **Trigger:** Der Ingress-Proxy (Caddy) oder ein lokaler Zugriff löst den Start via Systemd-Socket aus.
3.  **Timeout:** Dienste schalten sich nach X Minuten Inaktivität automatisch wieder ab.

## Begründung
- **Efficiency:** Drastische Reduzierung des Basis-RAM-Verbrauchs.
- **Hardware-Schutz:** Weniger Hintergrund-I/O schont die SSDs (Tier A).
- **Aviation-Grade:** Nur das, was gebraucht wird, belegt Ressourcen.

## Konsequenz
In \`modules/00-core/systemd.nix\` wird die globale Erlaubnis für Socket-Activation deklariert. Dienste wie \`sshd\` und \`caddy-internal\` werden als erste Kandidaten umgestellt.