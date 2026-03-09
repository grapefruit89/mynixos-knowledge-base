---
title: 📊 Automated Documentation & Visualization (Layer 50-knowledge)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [diagram-as-code, telemetry-plotting, qr-barcode-processing]
sources: [nixpkgs/pkgs/tools/graphics, graphviz docs, mermaid-cli]
---

# 📊 Visualisierung: Wissen sichtbar machen

In mynixos nutzen wir hocheffiziente Headless-Tools, um die System-Architektur und Telemetrie automatisch zu visualisieren.

## 🏛️ 1. Infrastructure-as-Code (Mermaid & Graphviz)
Wir nutzen textbasierte Beschreibungen für unsere Netzwerk-Pläne.
- **Dienst:** \`pkgs.graphviz\` und \`pkgs.mermaid-cli\`.
- **Anwendung:** Automatisches Rendering deiner \`ADRs\` in der Knowledge-Pipeline.

## 📈 2. Telemetrie-Plotting (Gnuplot)
Für die Langzeit-Überwachung der Hardware (Fuji Q958).
- **Nugget:** Gnuplot erzeugt statische Bilder aus CSV-Daten deiner Monitoring-Dienste (Layer 80).
- **Vorteil:** Keine riesige InfluxDB/Grafana-Instanz für einfache Hardware-Historien nötig. ✅

## 🏷️ 3. Dokumenten-Automation (Zbar)
Integration in den Dokumenten-Workflow (Layer 50).
- **Dienst:** \`pkgs.zbar\`.
- **Anwendung:** Automatisches Auslesen von QR-Codes auf gescannten Dokumenten zur Verschlagwortung in Paperless-ngx.

## 🚀 SRE-Vorteil
Diese Tools folgen dem **Headless-Gesetz (ADR-010)**. Sie benötigen keinen Desktop und belasten das System nur während des Generierungsvorgangs.