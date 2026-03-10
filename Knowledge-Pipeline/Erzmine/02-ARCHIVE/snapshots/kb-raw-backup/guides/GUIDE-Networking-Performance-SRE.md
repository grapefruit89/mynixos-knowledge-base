---
title: 📡 Networking Ops & Performance (Layer 00-core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [network-performance, path-analysis, spa-security, vpn-routing]
sources: [nixpkgs/pkgs/tools/networking, fwknop docs, mtr guide]
---

# 📡 Networking Ops: Deine Werkzeuge für den "God Mode"

In mynixos sind Netzwerk-Probleme keine Glückssache, sondern messbare Daten. Wir nutzen chirurgische Werkzeuge für die Analyse und Sicherheit.

## 💎 1. SPA Security (fwknop)
Der Tower bleibt "Dunkel" für Port-Scanner.
- **Konzept:** Single Packet Authorization (Kapitel 20).
- **Vorteil:** SSH ist von außen unsichtbar, bis ein signiertes Paket den Port öffnet.

## ⚡ 2. Bandbreiten-Audit (iperf3)
Wir betreiben den Tower als permanenten iperf3-Server.
- **Dienst:** \`services.iperf3.enable = true;\`
- **Anwendung:** \`iperf3 -c tower.m7c5.de\` von jedem Client im Haus.
- **SRE-Nutzen:** Sofortige Erkennung von fehlerhaften Kabeln oder überlasteten Switches. ✅

## 📊 3. Path Analysis (mtr)
Der Standard für die Fehleranalyse bei Streaming-Problemen.
- **Tool:** \`pkgs.mtr\`.
- **Vorteil:** Zeigt Latenz und Paketverlust an jedem Hop in Echtzeit.

## 🔄 4. VPN-Routing (vpn-slice)
Für selektives Routing in Layer 10-gateway.
- **Tool:** \`pkgs.vpn-slice\`.
- **Anwendung:** Trennung von privatem (lokalem) und öffentlichem (VPN) Traffic pro Dienst.