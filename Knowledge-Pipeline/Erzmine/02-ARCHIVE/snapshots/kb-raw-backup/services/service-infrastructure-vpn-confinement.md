---
title: "Architecture: VPN Confinement & Network Namespaces"
category: "infrastructure"
tags: [network, vpn, namespace, wireguard, security]
id: "NIXH-20-INF-007"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/20-infrastructure/vpn-confinement.nix"]
---

# Architecture: VPN Confinement

## 1. User Layer (KISS)
Dieses Modul ist die "Sicherheits-Schleuse" für deinen Datenverkehr. Es sorgt dafür, dass bestimmte Programme (wie Downloader) zwingend über eine VPN-Verbindung gehen müssen, während der restliche Server direkt und schnell mit dem Internet verbunden bleibt. Falls das VPN abbricht, wird der Internetzugriff für diese Programme sofort gekappt (Kill-Switch), um deine echte IP-Adresse niemals zu verraten.

## 2. Technical Layer (Aviation-Grade)

### Netzwerk-Isolation (Netns)
Anstatt den gesamten Host-Traffic zu tunneln, nutzt das System native Linux **Network Namespaces**:
*   **Namespace-Name:** `media-vault`.
*   **Host-IP (veth):** `10.200.1.1`.
*   **Namespace-IP:** `10.200.1.2`.
*   **Kill-Switch:** Da der Namespace keine eigene Default-Route außer dem VPN-Tunnel besitzt, ist ein IP-Leak technisch unmöglich.

### Implementierung (WireGuard)
Der Tunnel wird direkt im Namespace gestartet:
*   **Service:** `wireguard-vault.service`.
*   **Abhängigkeit:** Wartet auf die Entschlüsselung der Secrets (`sops-install-secrets.service`).
*   **Integration:** Dienste werden via `NetworkNamespacePath = "/run/netns/media-vault"` in die isolierte Umgebung injiziert.

### SRE Hardening
*   **RestrictAddressFamilies:** Beschränkt auf `AF_INET`, `AF_INET6` und `AF_UNIX`.
*   **Capabilities:** Der Namespace-Dienst läuft mit minimalen Rechten, die nur für das Netzwerk-Management erforderlich sind.

## 3. Reasoning Layer (History)

### [ADR-039] Netns vs. Global VPN
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Ein globaler VPN-Tunnel auf dem Host erschwert den Zugriff via SSH und Tailscale massiv und erhöht die Latenz für alle Dienste.
*   **Entscheidung:** Nutzung von granularen Namespaces.
*   **Vorteil:** Maximale Performance für Management-Traffic bei gleichzeitiger absoluter Sicherheit für den Download-Traffic.

### [ADR-040] Hardcoded Tunnel-IPs (10.200.1.x)
*   **Status:** Entschieden (März 2026).
*   **Begründung:** Die Nutzung eines fixen, nicht-routbaren IP-Bereichs für die Brücke zwischen Host und Namespace vereinfacht die Proxy-Konfiguration (`mkService`) erheblich, da das Ziel (`10.200.1.2`) immer identisch bleibt.

---
**Community-Abgleich:** Inspiriert von `nix-community/nixarr` und `ironicbadger/nix-config`.
