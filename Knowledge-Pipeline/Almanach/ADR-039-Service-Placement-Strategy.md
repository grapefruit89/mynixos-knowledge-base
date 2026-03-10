# [ADR-039]: Service Placement & Complexity Guard
# ID: [ADR-039] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir vermeiden es, das System durch zu viele isolierte Container unbedienbar zu machen. Wir unterscheiden klar zwischen Infrastruktur (Host), App-Verbund (Container) und Werkzeugen (Jail).

## 2. Die Zonen-Definition

### 🏠 Zone 0: Host-Native
- **Dienste:** Caddy, AdGuard, PostgreSQL, Forgejo, Tailscale.
- **Regel:** Maximale Performance, direkter Hardwarezugriff. Sicherheit erfolgt rein über `systemd-hardening` (ADR-009).

### 📦 Zone 1: The Media-Vault (Container)
- **Dienste:** Der komplette ARR-Stack + Player (Jellyfin/ABS).
- **Regel:** Diese Dienste werden als **ein einziger Verbund** in einen Container gesteckt. Sie teilen sich ein internes Netzwerk (10.200.1.x) und sehen sich gegenseitig als vertrauenswürdig an.

### 🛡️ Zone 2: Computational Jails (Bubblewrap)
- **Dienste:** Whisper STT, Python-Skripte, KI-Agenten.
- **Regel:** Kein Zugriff auf das Dateisystem außer /tmp. Nur CPU/RAM Nutzung.

## 3. Wartungs-Versprechen
Wir bauen keine verschachtelten Container-in-Container Setups. Die Fehlersuche muss über ein einfaches `journalctl -u container-name` möglich bleiben.

---
> [SOURCE]: Review der "Materialschlacht" (10.03.2026)
