---
title: "Service: Matrix-Conduit (Aviation-Grade Homeserver)"
category: "services"
tags: [communication, matrix, chat, rust, dendritic]
id: "NIXH-60-APP-005"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["60-apps/service-app-matrix-conduit.nix"]
---

# Service: Matrix-Conduit (Messenger Homeserver)

## 1. User Layer (KISS)
Matrix ist dein privater, sicherer Messenger – wie WhatsApp, nur dass der Server bei dir zu Hause steht. Conduit ist eine besonders schnelle und sparsame Version eines Matrix-Servers (geschrieben in Rust). Dieses Modul sorgt dafür, dass du mit anderen Matrix-Nutzern weltweit chatten kannst (Föderation), während alle deine Nachrichten sicher auf deinem Server gespeichert bleiben.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Performance
*   **Engine:** Conduit (Rust-basiert) via `services.matrix-conduit`.
*   **Datenbank:** Nutzt `rocksdb` für maximale Geschwindigkeit bei minimalem Ressourcenverbrauch.
*   **Ressourcen:** Begrenzt auf 1GB RAM (`MemoryMax`).

### Föderation & Ingress
*   **Domain:** Erreichbar über `matrix.nix.m7c5.de`.
*   **Discovery:** Automatische Konfiguration der `.well-known/matrix/server` und `client` Endpunkte in Caddy, damit andere Server deine Instanz finden können.
*   **Delegation:** Vollständige Unterstützung für verschlüsselte Kommunikation (E2EE).

### SRE Hardening & Security
*   **Sandboxing:** Nutzt die `mkService` Basis mit spezifischen Anpassungen für RocksDB.
*   **Isolation:** `StateDirectory = "matrix-conduit"`.
*   **No SSO:** Der Matrix-Server nutzt sein eigenes Identity-Management, um maximale Kompatibilität zu Matrix-Clients (Element, FluffyChat) zu gewährleisten.

### Integration (Nix-Snippet)
```nix
services.matrix-conduit = {
  enable = true;
  settings.global = {
    server_name = "matrix.nix.m7c5.de";
    database_backend = "rocksdb";
  };
};
```

## 3. Reasoning Layer (History)

### [ADR-068] Conduit vs. Synapse
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Synapse (Python) ist der Referenzserver, verbraucht aber oft mehrere GB RAM und benötigt eine PostgreSQL-Datenbank.
*   **Entscheidung:** Nutzung von Conduit.
*   **Vorteil:** Extrem ressourceneffizient (~50-100MB RAM im Normalbetrieb). Perfekt für das i3-9100 Host-System. Bietet alle für den Heimgebrauch relevanten Funktionen.

---
**Community-Abgleich:** Konform zu `nixpkgs/nixos/modules/services/matrix/matrix-conduit.nix`.
