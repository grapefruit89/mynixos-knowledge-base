---
title: "Service: Jellyfin Media Server (Aviation-Grade)"
category: "services"
tags: [media, jellyfin, gpu, qsv, dendritic]
id: "NIXH-40-MED-007"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/40-media/service-media-jellyfin.nix"]
---

# Service: Jellyfin Media Server

## 1. User Layer (KISS)
Jellyfin ist deine private Multimedia-Zentrale. Es sorgt für ruckelfreies Streaming deiner Filme und Serien durch direkte Nutzung deiner Grafikkarte (Intel QuickSync). Der Zugriff ist strikt abgesichert und nur aus vertrauenswürdigen Netzwerken erlaubt.

## 2. Technical Layer (Aviation-Grade)

### Hardware-Beschleunigung
* **QSV:** Nutzung von Intel QuickSync via iHD Treiber.
* **Config:** Deklarative encoding.xml Injektion via preStart.

### SRE Hardening
* **Network:** IPAddressDeny = "any" mit präziser Whitelist für lokale Subnetze.
* **Hardware:** Zugriff auf /dev/dri via DeviceAllow beschränkt.

## 3. Reasoning Layer (History)

### [ADR-032] Precision GPU Passthrough
Anstatt die Sandbox global zu lockern, werden für Jellyfin explizit nur die benötigten Grafik-Devices freigegeben. Dies minimiert das Risiko von Host-Kompromittierungen durch den Medien-Dienst.
