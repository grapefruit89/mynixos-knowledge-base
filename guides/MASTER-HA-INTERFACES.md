---
title: 🤖 Home Assistant MASTER-INTERFACE-LIST (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
capabilities: [rest-api, websocket-api, oidc-integration, native-orchestrierung]
sources: [https://developers.home-assistant.io/, https://github.com/home-assistant/architecture]
---

# 🤖 Home Assistant: Schnittstellen & Orchestrierung

In mynixos nutzen wir Home Assistant als zentralen Hub, steuern ihn aber rein deklarativ.

## 📡 1. REST API (Layer 80 Trigger)
Perfekt für System-Benachrichtigungen.
- **Endpunkt:** \`/api/states/<entity_id>\`
- **Authentifizierung:** Long-Lived Access Token (in Sops gesichert).
- **Beispiel:** Tower meldet niedrigen Festplattenplatz direkt an HA.

## 🔄 2. WebSocket API (Real-Time)
Wird von unserem Dashboard (Homepage) genutzt, um Live-Daten anzuzeigen.
- **Endpunkt:** \`/api/websocket\`

## 🔐 3. OIDC Authentication (Layer 40 Link)
Wir binden HA an unseren PocketID-Provider an.
- **Konfiguration:** Erfolgt via \`auth_providers\` in der \`configuration.yaml\`.

## 🛡️ SRE-Regel: No Supervisor
Da wir in NixOS arbeiten, sind wir unser eigener Supervisor.
- **Add-ons:** Alle Dienste (Mosquitto, Zigbee2MQTT, InfluxDB) werden als separate NixOS-Dienste (Dendriten) in \`modules/30-services/\` oder \`20-server/\` deklariert.
- **Kommunikation:** Ausschließlich via Netzwerk (MQTT / API). Keine physischen Abhängigkeiten zwischen den Containern/Diensten.