---
title: 💬 Sovereign Communication (Matrix Standard)
category: architecture/communications
status: [ACTIVE-SSoT]
capabilities: [matrix-protocol, decentralized-chat, sre-alerting]
sources: [https://github.com/matrix-org/matrix-spec, https://github.com/matrix-org/dendrite]
---

# 💬 Sovereign Communication: Der Matrix Standard

In mynixos ist Matrix nicht nur ein Chat, sondern die zentrale Nervenbahn für System-Events, Alerts und sichere Kommunikation.

## 🚀 Warum Matrix?
- **Souveränität:** Du besitzt deine Daten und deine Identität.
- **Interoperabilität:** Föderation erlaubt Kommunikation mit anderen Servern.
- **SRE-Ready:** Native Webhooks (\`matrix-hook\`) erlauben einfaches Alerting.

## 🏛️ Architektur-Wahl (Efficiency Gate)
Wir nutzen **Dendrite (Go)** oder **Conduit (Rust)**.
- **Vorteil:** Bruchteil des Ressourcenverbrauchs von Synapse (Python).
- **Hardening:** Die Datenbank wird via Sops-Secrets angebunden.

## 🧩 Modul-Integration (Layer 30-services)
Der Matrix-Dienst wird als Dendrit in \`modules/30-services/matrix.nix\` deklariert und injiziert seinen eigenen Caddy-Proxy (Ingress).