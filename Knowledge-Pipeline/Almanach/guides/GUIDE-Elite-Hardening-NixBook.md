# [GUIDE]: Elite Hardening & Workflow (Nix-Book)
# ID: [NUGGET-SRE-016] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & Prinzipien
Nach dem Vorbild des "Nix-Book" von saylesss88 streben wir eine totale Verzahnung von Hardware-Sicherheit und deklarativer Software an.

## 2. Die Elite-Komponenten

### 🔑 1. Der "Zündschlüssel" (USB-LUKS)
Anstatt Passwörter beim Booten einzutippen, nutzen wir ein Keyfile auf einem USB-Stick.
- **Vorteil:** Headless-Server (Q958) kann nach Stromausfall automatisch booten, aber nur wenn der physische Key steckt.
- **Nix-Modul:** `boot.initrd.luks.devices.<name>.keyFile = "/dev/disk/by-id/..."`.

### 🛡️ 2. Lanzaboote (Secure Boot)
Wir nutzen `lanzaboote`, um unsere eigenen UEFI-Signaturen zu verwalten.
- **Status:** Ersetzt den Standard `systemd-boot` Stub durch signierte Binaries.
- **Sicherheit:** Schließt die Lücke zwischen BIOS und Kernel.

### 🦀 3. Jujutsu (JJ) Version Control
Wir evaluieren `jj` als Nachfolger für `git` in der Werkstatt.
- **Warum:** Es ist in Rust geschrieben, extrem resilient gegen Fehlbedienung und bietet ein überlegenes Konfliktmanagement.

## 3. Strategische Einordnung
Diese Maßnahmen werden in **Phase 4 (Security Hardening)** der Roadmap umgesetzt.

---
> [SOURCE]: https://saylesss88.github.io/
