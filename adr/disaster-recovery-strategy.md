---
title: "Disaster Recovery: The Exclusive Token & DNA Strategy"
category: "adr"
tags: [security, recovery, s3, luks, dna, fingerprint, kiss]
date: 2026-03-08
source: "architectural-legacy-v6.1"
status: "verified-substance-v6.1-definitive"
---

# 🆘 [ADR-INFO]: SOUVERÄNE IDENTITÄT & RECOVERY (EXCLUSIVE TOKEN EDITION)

Dieses Dokument definiert den Sicherheitsstandard für den Master-USB-Stick und die vollautomatische Wiederherstellung.

---

## 🏗️ 1. USER LAYER: DAS "OMA-PRINZIP" (KISS)
Im Ernstfall ist keine Zeit für komplexe Befehle.
- **Stick rein, PC an.**
- Dein Handy meldet sich: "Server-Wiederherstellung starten?"
- **Tap auf "JA".**
- Das System heilt sich selbst über die Cloud.

---

## 🛠️ 2. TECHNICAL LAYER: DIE SICHERHEITS-KASAKDE

### A. Der Master-USB-Stick (Partition 2)
Der Stick enthält einen LUKS-verschlüsselten **Ignition-Seed**.
- **Entschlüsselung:** Slot 1 (TPM2 des Q958), Slot 2 (FIDO2/YubiKey für neue Hardware).
- **Inhalt:** S3-Access-Keys + Initial WLAN-Creds + Unique Hardware UUID.

### B. Passive Network DNA
Bevor der S3-Key genutzt wird, verifiziert die `initrd` den Standort.
- **Scan:** Ein passiver ARP-Scan sucht nach MAC-Adressen deiner IoT-Geräte (Shellys, Smart-TVs).
- **Match:** Nur wenn die Umgebung zu 70% bekannt ist, wird der Cloud-Sync freigegeben.

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum mDNS/Avahi?
Damit der Server im Rettungs-Modus ohne Monitor findbar ist (`mynixos-rescue.local`). Dein Smartphone wird zur grafischen Oberfläche für den Unlock.

### Warum physische Exklusivität?
Der Stick darf niemals für andere Daten genutzt werden. Er ist ein **Dedicated Token**, um Side-Channel Angriffe über Dateisysteme zu verhindern.
