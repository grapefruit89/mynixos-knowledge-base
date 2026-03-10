---
title: "Service: ARR-Wire (Automated API Integration)"
category: "services"
tags: [media, automation, api, sonarr, radarr, prowlarr]
id: "NIXH-40-MED-005"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/40-media/service-media-arr-wire.nix"]
---

# Service: ARR-Wire (API Key Automation)

## 1. User Layer (KISS)
Dieses Modul ist der "Hochzeitsplaner" deiner Medien-Dienste. Normalerweise musst du nach der Installation von Sonarr, Radarr und Prowlarr mühsam API-Schlüssel hin- und herkopieren, damit sie miteinander sprechen können. Dieses Modul macht das vollautomatisch im Hintergrund. Sobald die Dienste gestartet sind, "verdrahtet" es die Schlüssel, sodass alles sofort funktioniert, ohne dass du eine einzige Weboberfläche öffnen musst.

## 2. Technical Layer (Aviation-Grade)

### Funktionsweise & Extraktion
Der Dienst  wird als **Systemd-Oneshot** ausgeführt:
*   **Extraktion:** Er nutzt  und , um die API-Keys direkt aus den lokalen Konfigurationsdateien (, ) auszulesen.
*   **Injektion:** Via  werden die Schlüssel über die REST-APIs der Dienste injiziert.
*   **Orchestrierung:** Er wartet zwingend (), bis alle beteiligten Dienste bereit sind und ihre Konfigurationsdateien geschrieben haben.

### Sicherheits-Aspekt
*   **Keine manuellen Secrets:** Da die Schlüssel dynamisch extrahiert werden, müssen sie nicht in  oder Klartext-Dateien im Repository vorgehalten werden.
*   **Privilegien:** Der Dienst benötigt Lesezugriff auf die  Verzeichnisse der Dienste, was über systemd-Berechtigungen (oder Ausführung als root) gelöst wird.

### Integration (Nix-Snippet)


## 3. Reasoning Layer (History)

### [ADR-043] Dynamic Wiring vs. Static Secrets
*   **Status:** Entschieden (März 2026).
*   **Kontext:** API-Keys der ARR-Dienste werden bei der Erstinstallation oft zufällig generiert. Das manuelle Einpflegen in Nix-Dateien bricht den Automatisierungsfluss.
*   **Entscheidung:** Nutzung eines ID-basierten Extraktions-Skripts.
*   **Vorteil:** "Zero-Touch" Deployment des gesamten Media-Stacks. Das System konfiguriert sich nach einem Rebuild vollständig selbst.

### [ADR-044] Dependency on network-online.target
*   **Begründung:** Der Injektions-Vorgang via REST-API erfordert einen funktionierenden lokalen Netzwerk-Stack (), daher ist die Bindung an  zwingend.

---
**Community-Abgleich:** Erweitertes Konzept basierend auf den Automatisierungsideen des  Projekts.
