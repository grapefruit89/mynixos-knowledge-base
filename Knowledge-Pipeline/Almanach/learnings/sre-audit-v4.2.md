# 🧠 [LEARNINGS]: SRE Code Review & Hardening-Roadmap (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Dein System ist mächtig, hat aber momentan gefährliche Sicherheitslücken. Wir stellen es von "alles ist standardmäßig an" auf "Aviation-Grade" um – also so sicher wie ein Flugzeug-Cockpit.
- **Problem:** Momentan sind zu viele Dienste standardmäßig aktiv (registry.nix) und es gibt "Zeitbomben" wie Passwort-Login beim Booten.
- **Lösung:** Wir isolieren jeden Dienst, verstecken Passwörter sicher und sorgen dafür, dass das System nur das tut, was es wirklich soll.
- **Ziel:** Ein unzerstörbares, vorhersagbares NixOS-System, das auf jeder Hardware (Intel/ARM) läuft.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Detaillierte Spezifikation der identifizierten Schwachstellen und Gegenmaßnahmen.

### 🛑 2.1 Identifizierte "Zeitbomben" (Critical Findings)
1.  **Registry-Monolith:** `registry.nix` aktiviert 50+ Services via `lib.mkDefault true`. Führt zu Konfigurations-Drift und Sicherheitsrisiken durch ungenutzte, aber aktive Dienste.
2.  **SSH-Rescue Lücke:** `ssh-rescue.nix` öffnet Passwort-Authentifizierung für 5 Minuten nach jedem Boot. Klassisches Ziel für Race-Condition-Angriffe.
3.  **Plaintext Secrets:** `service-app-n8n.nix` enthält hardcodierte Encryption Keys im Nix-Store.
4.  **mTLS-Integrität:** P12-Zertifikate werden ohne Passwort öffentlich über Caddy bereitgestellt.
5.  **Netzwerk-Stack:** Fehlende sysctl-Härtung (ICMP Redirects, Source Route Acceptance) ermöglicht MITM-Angriffe im LAN.

### 🛠️ 2.2 Hardening Roadmap
- **HAL (Hardware Abstraction Layer):** Einführung von `00-core/hal.nix`, um Hardware-Abhängigkeiten (Intel/AMD/ARM) von den Diensten zu entkoppeln.
- **True Isomorphy:** Umstieg von `chunker.py` auf `nix eval` zur Metadaten-Extraktion (Single Source of Truth).
- **Service-Isolation:** Einsatz von `nftables` Micro-Segmentation (skuid-basiert) und `systemd` Sandboxing-Profilen (`mkHardenedService`).
- **Impermanence:** Umstellung auf `tmpfs` as Root, um Konfigurations-Drift physisch zu unterbinden.
- **Storage Broker (ABC-Tiering):** Zentrale Verwaltung von NVMe (Tier A), SSD (Tier B) und HDD (Tier C) via `hal-storage.nix`.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung: Warum dieser massive Umbau?
- **SRE Audit v4.2:** Das System ist aus seiner "Homelab-Experimentier-Phase" herausgewachsen. Die Komplexität von 50+ Diensten lässt sich nicht mehr manuell beherrschen.
- **Aviation-Grade Anspruch:** Um echte Hochverfügbarkeit und Sicherheit zu erreichen, muss das System **deklarativ unkorrumpierbar** sein. Impermanence ist hierfür das stärkste Werkzeug.
- **Isomorphie-Gebot:** Jedes Tool außerhalb des Nix-Ökosystems (wie Python-Parser) erhöht die Fehleranfälligkeit. Die Nix-Evaluierung muss das System selbst beschreiben können.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-03 Prompt-Übernahme anfragen.md` (Conversational SRE Review 3.3.2026).
