---
title: "Network DNA & Smartphone Push-Unlock"
category: "adr"
tags: [security, identity, dna, fingerprint, smartphone, ssh]
date: 2026-03-08
source: "raw/docs/Gemini-Stadtbibliothek Troisdorf_ Bürgergeld-Mitgliedschaft.md"
status: "verified-substance-v5.3"
---

# 🔐 [ADR-INFO]: IDENTITÄTS-VALIDIERUNG VIA NETWORK DNA (V5.3)

## 🧬 KONZEPT: DER NETZWERK-FINGERPRINT
Das System nutzt die physische Umgebung als kryptografischen Faktor. Wir speichern eine Liste von MAC-Adressen bekannter Geräte (Shellys, Smart-TVs) als "Vertrauens-Anker".

### Funktionsweise:
1. **Setup:** Nutzer führt `capture-network-fingerprint.sh` aus. Das System scannt das LAN und speichert die MAC-DNA verschlüsselt auf dem USB-Stick.
2. **Boot (initrd):** Das System führt einen ARP-Scan durch. Wenn mindestens X% der "Anker-Geräte" gefunden werden, gilt der Standort als "Home".

---

## 📱 AKTIVER UNLOCK: SMARTPHONE SSH-PUSH
Anstatt passiver Erkennung (WiFi-Leash) setzen wir auf eine aktive Autorisierung durch den Nutzer.

### Der Prozess:
1. **Trigger:** `initrd` erkennt die Network DNA (Standort verifiziert).
2. **Aktion:** Start eines minimalen SSH-Dienstes (Dropbear) auf Port 2222.
3. **User-UX:** Dein Smartphone sendet bei Erkennung des Boot-Vorgangs eine Push-Benachrichtigung. Ein Tastendruck in einer App (z.B. Termius/Tasker) sendet den Entsperr-Key sicher an den Server.
4. **Vorteil:** Maximale Sicherheit. Selbst im Heimnetz muss der Besitzer physisch anwesend sein und den Boot aktiv bestätigen.

---

## 🏛️ ARCHITEKTUR-ENTSCHEIDUNGEN (VEREINFACHT)

### 1. TPM2 ODER FIDO2 (Slot-Priorität)
Wir nutzen LUKS-Multi-Slotting für maximale Redundanz ohne Komplexität:
- **Slot 1:** TPM2 (Vollautomatisch auf autorisierter Hardware).
- **Slot 2:** FIDO2 (Manueller Hardware-Token für Portabilität).
- **Logik:** Das System prüft beide Slots parallel. Der erste erfolgreiche Token entsperrt das System.

### 2. Monitor-loser Fallback (mDNS/Avahi)
Um den Server ohne Monitor zu administrieren, wird `mDNS` in der `initrd` aktiviert.
- **Adresse:** `mynixos-rescue.local`
- **Funktion:** Ermöglicht den Zugriff auf das Rettungs-Interface via Webbrowser am Smartphone, falls der Push-Unlock fehlschlägt.

> [ARCHITECT-NOTE]: Diese Kombination aus **passiver DNA (Wo bin ich?)** und **aktivem Push (Wer bin ich?)** erfüllt den "Aviation-Grade" Standard für souveräne Identität.
