---
title: ✂️ Kernel Surgical Diet (Layer 00-core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [legacy-ejection, hardware-optimization, attack-surface-reduction]
sources: [Linux Kernel Config Reference, Gentoo Minimal Kernel Guide]
---

# ✂️ Kernel-Diät: Nur das, was dein Q958 wirklich braucht

In mynixos lehnen wir monolithischen Bloat ab. Wir schalten alles ab, was vor 2015 relevant war oder nur in Rechenzentren existiert.

## 🏛️ 1. Die Ejektions-Liste (What's Gone)
Wir deaktivieren folgende Subsysteme via \`boot.kernelPatches\` oder \`boot.kernel.sysctl\`:
- **Amateurfunk:** AX.25, Rose, NET/ROM (HAMRADIO).
- **Legacy Networking:** Appletalk, IPX, X.25, Token Ring.
- **Legacy Storage:** Floppy, CD-ROM (ISO9660), IDE (alt).
- **Enterprise-Bloat:** InfiniBand, FiberChannel, DCM (Data Center Management).

## ⚙️ 2. Die NixOS Umsetzung (The Slim-Profile)
Hier ist das Muster für deinen Dendriten (\`modules/00-core/kernel-slim.nix\`):

\`\`\`nix
boot.kernelPatches = [ {
  name = "mynixos-slim-diet";
  patch = null;
  extraConfig = ''
    # Amateurfunk raus
    HAMRADIO n
    AX25 n
    # Legacy Hardware raus
    FIREWIRE n
    ISDN n
    # Enterprise Bloat raus
    INFINIBAND n
    SCSI_LOWLEVEL n
  '';
} ];
\`\`\`

## 🛡️ 3. SRE-Vorteil
- **Speed:** Schnellere Boot-Zeiten, da weniger Treiber initialisiert werden müssen.
- **Security:** Was nicht geladen ist, kann nicht angegriffen werden (Zero-Day Schutz). ✅
- **Memory:** Kleinerer Kernel-Footprint lässt mehr RAM für deine Dienste.

## 🚀 SRE-Anwendung
Diese Konfiguration wird in \`90-policy/no-legacy.nix\` erzwungen. Werden Treiber aus der Ejektions-Liste angefordert, bricht der Build mit einer Assertion ab.