# [MAP]: MyNixOS Service Map
# ID: [NUGGET-SRE-017] | Stand: 10.03.2026

Diese Karte zeigt, wie die Zonen ineinandergreifen.

```mermaid
graph TD
    subgraph "ZONE 0: HOST (The Foundation)"
        C[Caddy Ingress]
        DB[PostgreSQL]
        TS[Tailscale]
        FJ[Forgejo]
    end

    subgraph "ZONE 1: MEDIA VAULT (Container)"
        direction LR
        P[Prowlarr] <--> S[Sonarr]
        S <--> R[Radarr]
        R <--> J[Jellyfin]
    end

    subgraph "ZONE 2: JAILS (Ephemeral)"
        W[Whisper STT]
        G[Gemini Tools]
    end

    C -- "Port 80/443" --> P
    C -- "Port 80/443" --> J
    DB <-- "TCP" --> S
    DB <-- "TCP" --> R
```

---
> [ARCHITECT-NOTE]: Diese Struktur minimiert die "Falschstrick-Gefahr", da die Grenzen klar definiert sind.
