---
title: Architecture-Sovereign-Identity-Hardware-Auth (Aviation-Grade Nugget)
category: architecture/legacy-import
capabilities: [archived-knowledge, traceability-fix]
sources: [https://github.com/mightyiam/best-of-nix]
---

# Architecture: Hardware-Auth & Network-Bound Encryption (NMS v4.2)

## 1. User Layer (KISS)
Dieses Dokument beschreibt die "Easy-Access" Strategie für den sicheren und bequemen Systemstart. Das Ziel ist ein "Zero-Touch" Bootvorgang im heimischen Netzwerk, während das System unterwegs (oder bei Diebstahl) maximale Sicherheit durch Hardware-Token (YubiKey) und Passwörter verlangt. Wir nutzen dein vorhandenes Smarthome-Netzwerk (Shellys, Router) als digitalen Fingerabdruck, um zu erkennen, ob der Server "zu Hause" ist.

## 2. Technical Layer (Aviation-Grade)

### Multi-Layer Unlock Strategie
Die Entschlüsselung der Systempartition folgt einer definierten Eskalationskette:
1.  **Phase 1: Network Fingerprinting (Auto-Unlock):**
    *   In der `initrd` scannt das System via ARP das lokale Netzwerk.
    *   Vergleich der gefundenen MAC-Adressen mit einer verschlüsselten Whitelist (`trusted_macs`).
    *   Bei einer Übereinstimmung von > X Geräten (Ankern) erfolgt der Key-Release via TPM 2.0.
2.  **Phase 2: FIDO2 / YubiKey (Physical Presence):**
    *   Falls Phase 1 fehlschlägt (z.B. unterwegs), wartet das System auf die Berührung eines registrierten FIDO2-Tokens (YubiKey).
3.  **Phase 3: SSH Remote Unlock (Smartphone/PC):**
    *   Ein minimaler SSH-Server in der `initrd` (Port 2222) erlaubt die verschlüsselte Eingabe der Passphrase via Smartphone-App (z.B. Termius).

### Implementierung: Initrd-Konfiguration (Nix-Snippet)
```nix
boot.initrd = {
  systemd.enable = true;
  network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = [ "sk-ecdsa-sha2-nistp256@openssh.com ..." ];
      hostKeys = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
    # Dynamisches Bridge-Setup für Fujitsu Q958
    postCommands = ''
      ip addr add 192.168.2.73/24 dev br0
      ip route add default via 192.168.2.1
    '';
  };
  luks.devices."cryptroot" = {
    device = "/dev/disk/by-id/usb-IDENTITY_STICK-part2";
    crypttabExtraOpts = [ "tpm2-device=auto" "fido2-device=auto" ];
  };
};
```

### Script: Network-Fingerprint Generation
Ein Hilfsskript erfasst die MAC-Adressen der Umgebung und speichert sie als Hash für die `initrd` (Learning Mode).
```bash
# ARP-Scan im Subnetz
for i in {1..254}; do (ping -c 1 -W 1 192.168.2.$i >/dev/null 2>&1 &); done
sleep 2
ip neighbor show dev br0 | grep -E "REACHABLE|STALE" | awk '{print $5}' > trusted_macs.txt
```

## 3. Reasoning Layer (History)

### [ADR-004] Dynamic Network Anchoring vs. Tang-Server
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Ein klassischer Tang-Server benötigt zusätzliche Hardware (NAS/Pi), die permanent laufen muss. Für ein portables System (oder Weitergabe an Dritte) ist dies zu unflexibel.
*   **Entscheidung:** Nutzung von **Network Fingerprinting**. Vorhandene, statische Netzwerkgeräte (Shellys, Smart-TVs, Router) fungieren als passive Anker.
*   **Vorteile:** Keine extra Hardware nötig. "Brother-Ready": Das System kann in fremden Netzwerken neu "angelernt" werden, indem ein neuer Fingerprint der dortigen Geräte erstellt wird.
*   **Sicherheits-Abwägung:** MAC-Spoofing ist möglich, daher dient der Netzwerk-Check nur als **Zusatzfaktor** (Condition) zur Freigabe des TPM-Keys, nicht als alleiniges Sicherheitsmerkmal.

---
**Sources:**
*   `/home/Knowledge-Pipeline/raw/_duplikate/Gemini-Stadtbibliothek Troisdorf_ Bürgergeld-Mitgliedschaft.md`
*   `/home/Knowledge-Pipeline/raw/_duplikate/NMS_v4.2_SOVEREIGN_IDENTITY_AUDIT.md`
