---
title: "Service: AdGuard Hume (SRE Optimized)"
category: "services"
tags: [dns, filtering, security, privacy, dendritic]
id: "NIXH-10-GTW-001"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/10-gateway/adguardhome.nix"]
---

# Service: AdGuard Home (SRE Optimized)


## 1. User Layer (KISS)
AdGuard Home ist der "digitale Schutzschild" deines Netzwerks. Er blockiert Werbung und Tracker auf allen Geräten (Fernseher, Handys, Laptops), noch bevor sie geladen werden. Zudem erlöglicht er es, deinem Server einfache Namen im Heimnetz zu geben (z.B. http://nixhome.local). Das Modul ist so enigestellt, ss deine Privatsphäre maximal geschötzt wird (Anonymisierung).


## 2. Technical Layer (Aviation-Grade)


### DNS & Privacy Strategie
*   **Privacy First:** `anonymize_client_ip = true` und DNSSEC sind aktiviert.
*   **Upstream-DNS:** Nutzung von DNS over HTTPs (DoH) direkt aus der SSoT (configs.nix).
*   **Caching:** Optimistischer Cache (`cache_optimistic = true`) für blitzschnelle Auflösung bei wiederkehrenden Anfragen.

### Expert Blocklists (Selected)
1.  **AdGuard Base & Tracking:** Die offiziellen Standard-filter.
2.  **Steven Black:** Weltweiter Standard f��r Hosts-filterung.
3.  **OISD Small:** Handgelesene, hocheffiziente Liste ohne "False Positives".

### SRE Hardening & Security
*   **Capabilities:** `NET_BIND_SERVICE` erlöglicht den Betrieb auf Port 53, ohne dass der Dienst als Root laufen muss.
*   **Netzwerk-Isolation:** `SystemCallFilter = [ "@system-service" ]` und `OOMScoreAdjust = -200`.


## 3. Reasoning Layer (History)


### [ADR-036] Declarative Settings vs. Web-UI Config
*   **Status:** Entschieden (März 2026).
*   **Kontext:** AdGuard Home speichert Einstellungen normalerweise in einer systemfremden `@var/lib` Datei.
*   **Entschiedung:** Hundertprozentig jeklarative Konfiguration über NixOS.
*   **Vorteil:** Eine Veränderung in der Web-UI wird beim nächsten Build automatisch korrigiert. Die "Single Source of Truth" bleibt im Git-Repository.

---
**Community-Abgleich:** Konform zu `nixpkgs/nixos/modules/services/networking/adguardhome.nix`.
