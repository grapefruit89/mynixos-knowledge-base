---
title: "Sovereign Identity v4 & Zero-Touch Boot"
category: "adr"
tags: [security, identity, zero-touch, boot, tpm]
date: 2026-03-08
source: "raw/_duplikate/Gemini-Python-Prozess verursacht hohe Systemlast.md"
status: "live-validated-v4.2"
---

# 🔐 [ADR-INFO]: Sovereign Identity & NMS v4.2 Architektur-Säulen

Dieses Konzept definiert die "Zero-Touch" Security-Pipeline des NixOS Systems, bei dem ein Master-USB-Stick und kryptografische Hardware-Tokens das Bootstrapping absichern.

> **Verwandte Konzepte:** 
> - [NixHome Architecture](nixhome-architecture.md)
> - [Identity Security Audit](identity-security-audit.md) (Für die Analyse der Boot-Deadlocks)

## 🏛️ Architektur-Säulen des NMS v4.2

### 1. Impermanenz (Das Hotelzimmer-Prinzip)
- **Konzept:** Das Betriebssystem ist bei jedem Start "frisch". Alles nicht explizit Persistierte existiert nur im RAM (`tmpfs`).
- **Funktion:** Verhindert State-Drift und erzwingt saubere Deklarationen.

### 2. HAL (Hardware Abstraction Layer)
- **Konzept:** Software ist "blind" für die Hardware. Anfragen (z.B. Hardware-Transcoding für Jellyfin) laufen über abstrakte HAL-Optionen anstatt direkter Hardware-Referenzen, was Migrationen ermöglicht.

### 3. ABC Storage Tiering
- **Tier A (NVMe):** Datenbanken, App-State (schnell).
- **Tier B (SSD):** Cache, Temporäre Daten, Transcoding.
- **Tier C (HDD):** Archiv für Medien (Filme, Audio).

### 4. Sovereign Identity (Der Master-USB-Stick)
- **Konzept:** Der Master-USB-Stick ist der digitale Reisepass.
- **Funktion:** Das System identifiziert den Stick per Hardware-ID. Er dient als initialer "Generalschlüssel", wird aber NICHT im Dauerbetrieb gemountet (Plug-and-Sync). 

### 5. Encrypted State-Streaming (Cloud-Anker)
- **Konzept:** Nur absolut kritischer App-State (< 10GB) wird via Restic verschlüsselt in die Cloud synchronisiert.
- **Funktion:** Ermöglicht Disaster-Recovery auf neuer Hardware innerhalb von Minuten, sofern der Master-Stick vorhanden ist.

## 🚀 Die Zero-Touch Boot-Kaskade (Sovereign UX)

Die Entschlüsselung (LUKS) durchläuft eine Sicherheits-Kaskade von "vollautomatisch" bis "manuell-souverän".

| Szenario | Primärer Key-Faktor | User-Aktion |
| --- | --- | --- |
| **Identische Hardware** | TPM2 Chip (PCR 0+1+7) | **Keine** (Vollautomatisch) |
| **Heimnetz / NAS anwesend** | Tang-Server / MAC-DNA | **Keine** (Vollautomatisch) |
| **Fremdnetz / Unterwegs** | FIDO2 (YubiKey) | **1x Button drücken** |
| **Totaler Hardware-Wechsel** | SSH via Smartphone | **Passwort vom Handy pasten** |

> [LIVE-ENRICHMENT]: In NixOS 24.11+ und 25.05+ wird die systemd-initrd (`boot.initrd.systemd.enable = true`) zum Standard. Das Tool `systemd-cryptenroll` integriert TPM2 und FIDO2 direkt in den Boot-Prozess, was Clevis in vielen Fällen überflüssig macht. Tang wird jedoch weiterhin für Network Bound Disk Encryption benötigt.

### Implementierung der Boot-Kaskade (Auszug)

```nix
{ config, lib, pkgs, ... }:
{
  boot.initrd.systemd.enable = true;

  # MULTI-FACTOR DECRYPTION (LUKS) via systemd-cryptsetup
  boot.initrd.luks.devices."bootstrap_vault" = {
    device = "/dev/disk/by-label/NIXHOME_CRYPT";
    # Nutze TPM2 oder FIDO2 automatisch falls verfügbar
    
> [LIVE-ENRICHMENT]: Für die **FIDO2-Hardware-Attestierung** (YubiKey) sollten folgende Optionen in der `crypttab` (via `crypttabExtraOpts`) gesetzt werden, um eine PIN-Abfrage zu erzwingen und die Sicherheit zu erhöhen:
> ```nix
> boot.initrd.luks.devices."bootstrap_vault".crypttabExtraOpts = [ 
>   "fido2-device=auto" 
>   "fido2-with-client-pin=yes" # Erfordert physischen Touch + PIN am Token
> ];
> ```

  };

  # Clevis-Unterstützung für Netzwerk-gebundene Verschlüsselung (Tang)
  boot.initrd.clevis = {
    enable = true;
    devices."bootstrap_vault".secretFile = "/run/network-is-home";
  };
}
```

## 🧬 Network DNA (Fuzzy-Logic Guard)

Vor dem Tang-Handshake prüft die `initrd` die physische Umgebung durch ARP-Checks auf bekannte Nachbar-Geräte (Router, NAS).

```bash
# Konzept: Passive DNA-Analyse via arping
if arping -c 1 -I eth0 -f -q -b $ROUTER_MAC 2>/dev/null; then
  echo "Router-DNA verifiziert."
  touch /run/network-is-home
fi
```
> [ARCHITECT-NOTE]: Diese Prüfung verhindert, dass der Server in einem feindlichen Netzwerk versucht, Keys anzufordern (Phone-Home-Leak). Nur wenn die Anker stimmen, wird der Tang-Prozess gestartet.
