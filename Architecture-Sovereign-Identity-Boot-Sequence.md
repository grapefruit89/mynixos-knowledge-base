# Architecture: Sovereign Identity & Boot-Sequence (NMS v4.2)

## 1. User Layer (KISS)
Dieses Dokument beschreibt, wie der NixOS-Server (q958) sicher startet, wenn die Identität (Verschlüsselungs-Keys) auf einem physischen USB-Stick liegt. Wir lösen das Problem, dass der Server beim Starten gleichzeitig auf das Internet, den USB-Stick und verschlüsselte Passwörter warten muss. Die Lösung ist eine präzise "Handoff-Kette", bei der jeder Schritt genau zur richtigen Zeit passiert, ohne das System zu blockieren.

## 2. Technical Layer (Aviation-Grade)

### Die Identitäts-Handoff-Kette (Deadlock-Free)
Um die vier identifizierten Deadlocks (Netz, USB-Validierung, sops-nix, Restic-Pull) zu lösen, folgen wir dieser Sequenz:

1.  **Stage 1 (initrd):**
    *   Identifikation des USB-Sticks via `/dev/disk/by-id/usb-SERIENNUMMER-*` (Hardware-Seriennummer im Pfad, kein udev nötig).
    *   Entschlüsselung der LUKS-Partition 2 (Stick) via TPM 2.0 oder Passwort.
    *   Öffnen der Tier-A NVMe LUKS-Partition mit dem Key vom Stick.
2.  **Stage 2 (systemd - Vorbereitungsphase):**
    *   Netzaufbau via DHCP auf Kabel-Interface (ohne Secrets).
    *   Mount der USB-Partition 2 nach `/mnt/sovereign-identity`.
    *   Aktivierung von `sops-install-secrets.service` (bezieht Age-Key vom Stick).
    *   **State Restore:** `sovereign-state-restore.service` führt `restic restore` aus S3 durch (Credentials aus sops-Secrets).
3.  **Stage 3 (Vollständige Identität):**
    *   Start von Tailscale (Auth-Key nun in `/run/secrets/` verfügbar).
    *   Start von AdGuard, PostgreSQL etc. (Data aus `/mnt/tier-a/state/`).

### Sicherheits-Konfiguration (Nix-Snippets)
```nix
# Verzögerung von Diensten bis Secrets verfügbar sind
systemd.services.tailscaled = {
  after = [ "sops-install-secrets.service" "network-online.target" ];
  requires = [ "sops-install-secrets.service" ];
};

# Restic Restore mit Emergency-Mode bei Fehlschlag
systemd.services.sovereign-state-restore = {
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.restic}/bin/restic restore latest --target /mnt/tier-a/state";
    SuccessExitStatus = "0 1"; # 1 = kein Snapshot (Init-Fall)
  };
};
```

## 3. Reasoning Layer (History)

### [ADR-003] Sovereign Identity Boot Deadlocks
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Die ursprüngliche Planung (naives Konzept) führte zu vier zirkulären Abhängigkeiten (Deadlocks), bei denen das Netzwerk auf Secrets wartete, die wiederum das Netzwerk zum Download benötigten.
*   **Entscheidung:** Einführung einer mehrphasigen Boot-Strategie. Das Netzwerk-Bootstrapping (DHCP) wird von der Secret-Abhängigkeit (Tailscale) entkoppelt. Die USB-Validierung erfolgt hardwarebasiert (`by-id`) bereits in der `initrd`.
*   **Konsequenzen:** Der Bootvorgang ist deterministisch. Ein Fehlschlag des Cloud-Pulls (Restic) führt zum Stopp des Bootvorgangs, um Dateninkonsistenzen (Überschreiben des Cloud-States mit leerem Lokal-State) zu verhindern.
*   **Verworfene Alternativen:** 
    *   `[SUPERSEDED]` WLAN-Key auf dem Stick: Unnötig für kabelgebundene Server und löst das Tailscale-Problem nicht.
    *   `udev`-Service für USB-Validierung in Stage 1: Technisch nicht möglich, da `udev` in `initrd` nur eingeschränkt zur Verfügung steht.

---
**Sources:**
*   `/home/Knowledge-Pipeline/raw/_duplikate/NMS_v4.2_SOVEREIGN_IDENTITY_AUDIT.md`
*   `/home/Knowledge-Pipeline/raw/_duplikate/Claude-NMS v4.2 sovereign identity implementation strategy.md`
