---
title: "Service: Zigbee Stack (Aviation-Grade)"
category: "services"
tags: [iot, zigbee, mqtt, home-automation, dendritic]
id: "NIXH-20-INF-004"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/20-infrastructure/service-app-zigbee-stack.nix"]
---

# Service: Zigbee Stack (MQTT & Z2M)

## 1. User Layer (KISS)
Dieses Modul ist das "Nervensystem" deines Smarthomes. Es verbindet deine Zigbee-Geräte (Lichter, Sensoren) mit Home Assistant. Durch die Anbindung des Sticks über das Netzwerk (SLZB-06) ist der Empfang überall im Haus optimal.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Komponenten
* **Broker:** Mosquitto (lokal) für den Datenaustausch.
* **Control:** Zigbee2MQTT zur Geräteverwaltung.
* **Adapter:** Netzwerk-Anbindung via TCP (Ember-Adapter-Typ).

### SRE Hardening
* **Sandbox:** Nutzt ProtectSystem = "strict" und PrivateTmp.
* **Netzwerk:** IP-Beschränkung auf localhost für MQTT-Kommunikation.

## 3. Reasoning Layer (History)

### [ADR-047] Network-TCP adapter vs. USB-Passthrough
Um Instabilitäten durch USB-Treiber zu vermeiden, wird ein dedizierter Netzwerk-Zigbee-Stick genutzt. Dies ermöglicht zudem eine freie Positionierung des Sticks für maximale Funkabdeckung.
