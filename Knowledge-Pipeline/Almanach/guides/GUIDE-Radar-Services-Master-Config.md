---
title: 📡 Under-the-Radar Services (Zigbee, MQTT, nftables)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [iot-communication, firewall-mastery, declarative-iot]
sources: [NixOS Search, official nixpkgs modules]
---

# 📡 Under-the-Radar: Die versteckten Kraftpakete

In mynixos nutzen wir spezialisierte Dienste für das Fundament und die IoT-Kommunikation.

## 🛡️ 1. nftables: Der Aviation-Grade Schutz
Wir ersetzen die veralteten \`iptables\` durch \`nftables\`.
- **Vorteil:** Schnellere Paketverarbeitung, atomare Updates der Firewall-Regeln.
- **Strategie:** Wir definieren die Regeln in \`modules/00-core/firewall.nix\`.

## 📡 2. Mosquitto (MQTT): Die Nervenbahn (Layer 20)
Zentraler Message-Broker für Home Assistant und Zigbee2MQTT.
- **Sicherheit:** Wir erzwingen Authentifizierung für alle Listener.
- **Nix-Config:** \`services.mosquitto.enable = true;\`

## 🕹️ 3. Zigbee2MQTT: IoT-Brücke (Layer 30)
Verbindet deine Zigbee-Geräte mit dem MQTT-Netzwerk.
- **Konfiguration:** Alle Einstellungen (PanID, Port, NetworkKey) kommen aus dem Sops-Tresor.
- **Nix-Config:** \`services.zigbee2mqtt.settings = { ... };\`
