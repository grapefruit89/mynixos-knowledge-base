---
title: 🔐 SSH Infrastructure Mastery (Advanced Core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [remote-luks-unlock, binary-cache-ssh, tmate-sharing, sshfs-integration]
sources: [nixpkgs/nixos/modules/system/boot/initrd-ssh.nix, nix-ssh-serve.nix]
---

# 🔐 SSH: Mehr als nur eine Shell

In mynixos nutzen wir SSH als das primäre Transport- und Kontroll-Layer für alle System-Operationen.

## 💎 1. Remote LUKS Unlock (Initrd SSH)
Für unseren headless Tower ist dies die wichtigste Sicherheits-Funktion.
- **Dienst:** \`boot.initrd.network.ssh.enable = true;\`
- **Nutzen:** Ermöglicht die Eingabe des Festplatten-Passworts via SSH, bevor das eigentliche System startet.
- **SRE-Security:** Nutzt dedizierte SSH-Keys, die nur im Boot-Vorgang existieren.

## 📦 2. Nix Binary Serving (\`nix-ssh-serve\`)
Der Tower agiert als privater Cache für andere Nix-Geräte im Haus.
- **Dienst:** \`services.nix-ssh-serve.enable = true;\`
- **Vorteil:** Schnelle Verteilung von Builds ohne Internet-Abhängigkeit.

## 📂 3. SSHFS (FUSE-Integration)
Wir nutzen SSHFS für ad-hoc Dateisystem-Einbindungen.
- **Pattern:** \`sshfs user@tower:/mnt/storage /home/user/tower-mount\`
- **Vorteil:** Keine permanenten Mounts (fstab) für flüchtige Daten-Migrationen nötig.

## 🛠️ 4. Tmate Support
Für Notfall-Support oder kollaboratives SRE-Debugging.
- **Dienst:** \`services.tmate-ssh-server.enable = true;\`