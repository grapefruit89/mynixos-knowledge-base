# Service: Policy Enforcement & Legacy Protection

## 1. User Layer (KISS)
Dieses Dokument beschreibt die "Hausordnung" deines Servers. Wir verbieten dem System die Nutzung veralteter oder unsicherer Techniken (Legacy). Wenn du versuchst, eine alte Methode (wie ein klassisches Start-Skript) zu nutzen, wird der Server den Dienst verweigern und dir stattdessen die moderne, sichere Alternative vorschlagen. Das hält dein System schlank, schnell und zukunftssicher.

## 2. Technical Layer (Aviation-Grade)

### Architektur der Schutzregeln
Das Modul implementiert einen dreistufigen Schutzwall:
1.  **Boot-Schutz:** Verbot von GRUB (BIOS-Legacy) zugunsten von `systemd-boot` (UEFI).
2.  **Dateisystem-Schutz:** Deaktivierung alter Kernel-Treiber (z.B. `ntfs`, `ext2`, `reiserfs`), um die Stabilität des Kernels zu erhöhen.
3.  **Netzwerk-Schutz:** Erzwingung von `nftables` (statt altem iptables) und Deaktivierung des ressourcenintensiven `NetworkManager`.

### Die Binary-Only Mauer
*   **Regel:** `nix.settings.max-jobs = 0`.
*   **Veto:** Eine Nix-Assertion bricht den Build ab, falls versucht wird, diese Regel zu umgehen. Dies garantiert, dass der Server niemals durch Kompilierungslast blockiert wird.

### Integration (Nix-Snippet)
```nix
config.assertions = [
  {
    assertion = !config.services.cron.enable;
    message = "🚫 Nutze systemd.timers statt cron!";
  }
];
```

## 3. Reasoning Layer (History)

### [ADR-031] Strict No-Legacy Policy
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Viele Sicherheitslücken entstehen durch Abwärtskompatibilität zu Protokollen der 90er Jahre.
*   **Entscheidung:** Strikte Absage an Legacy-Komponenten.
*   **Vorteile:** Minimaler RAM-Footprint, schnellere Bootzeiten und eine saubere Codebase ohne Altlasten.
*   **Konsequenz:** Alle Dienste müssen nativ in systemd-Units und nftables-Regeln deklariert werden.

---
**Sources:**
*   `90-policy/no-legacy.nix`
*   `90-policy/binary-only.nix`
*   `00-core/nix-tuning.nix`
