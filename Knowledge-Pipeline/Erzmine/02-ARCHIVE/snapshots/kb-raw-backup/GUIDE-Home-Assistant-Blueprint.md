---
title: 🤖 Home Assistant Blueprint (Aviation-Grade Automation)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [home-automation, iot-security, nixos-integration]
sources: [https://github.com/ironicbadger/awesome-home-assistant]
---

# 🤖 Home Assistant: Der Automatisierungs-Kern

In mynixos ist Home Assistant der Dirigent deiner physischen Umgebung. Wir betreiben ihn nativ (Layer 30) für maximale Performance.

## 🏛️ Architektur-Entscheidungen (SRE Standard)
1.  **Native-First:** Wir nutzen `services.home-assistant.enable`. Keine Docker-Container für HA.
2.  **Privilege Separation:** Zigbee2MQTT und Mosquitto laufen als separate Dendriten (Layer 20-server). HA greift nur via MQTT darauf zu.
3.  **Sops-Secrets:** Long-Lived Access Tokens werden via Sops-Nix verwaltet.

## 🛡️ Ingress & Security
- **Internal Only:** Home Assistant ist standardmäßig NUR über das Tailnet erreichbar.
- **mTLS:** Optionaler externer Zugriff erfolgt über Caddy mit mTLS-Zertifikaten (Aviation-Grade Zero-Trust).

## 🚀 Empfohlene Integrationen (aus Awesome-HA)
- **HACS:** Für Community-Integrationen.
- **Config-Check:** Wir integrieren einen Build-Check (Layer 90), der die HA-YAML Konfiguration vor dem Deployment validiert.