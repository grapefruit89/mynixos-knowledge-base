# [GUIDE]: Perfect Media Server Architecture (Ironic Badger)
# ID: [NUGGET-SRE-019] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & Prinzipien
Nach den Prinzipien von Alex Kretzschmar (Ironic Badger) bauen wir einen PMS, der auf **Pragmatismus, Wartbarkeit und Souveränität** beruht.

## 2. Die Architektur-Entscheidungen (ADR-Mining)

### 🗄️ A. Storage: Tiering statt Monolith
- **Tier A (Performance):** ZFS Mirror auf NVMe für OS, Datenbanken und Container-Config. (Bitrot-Schutz & Snapshots).
- **Tier C (Bulk Media):** mergerfs + SnapRAID.
  - **Warum?** Mischen von Festplattengrößen möglich. Platten bleiben im Standby (Stromersparnis), wenn nicht zugegriffen wird.

### 🔌 B. Ingress: Caddy Mastery
- **Entscheidung:** Caddy als Standard-Reverse-Proxy.
- **Vorteil:** Automatisches SSL, einfache Syntax, Native NixOS Integration.

### 🔑 C. Secrets: Sops-Nix
- **Entscheidung:** sops-nix ist der Goldstandard für das Secret-Management auf NixOS.

## 3. Strategische Einordnung
Wir folgen dem PMS-Standard für den Media-Stack (mergerfs), veredeln ihn aber durch unsere **Aviation-Grade Hardening** (ADR-038) im Media-Vault.

---
> [SOURCE]: https://perfectmediaserver.com/ & https://github.com/ironicbadger/nix-config
