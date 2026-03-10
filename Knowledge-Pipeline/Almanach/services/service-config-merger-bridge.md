# Service: Hybrid Config Merger (Nix-to-JSON Bridge)

## 1. User Layer (KISS)
Dieses Dokument beschreibt den "Übersetzer" deines Systems. Da nicht alle Programme (wie Web-Oberflächen oder Skripte) die Sprache von NixOS verstehen, übersetzt dieses Modul deine wichtigsten Einstellungen (Domain, IP, E-Mail) automatisch in eine einfache JSON-Datei. Du kannst dort sogar eigene Einstellungen hinzufügen, die dann sofort vom System übernommen werden, ohne dass du den ganzen Server neu starten musst.

## 2. Technical Layer (Aviation-Grade)

### Architektur der Bridge
Das Modul agiert als SSoT-Exporteur für Nicht-Nix-Komponenten:
1.  **Export:** Nix-Optionen (`config.my.configs.*`) werden via `builtins.toJSON` in ein statisches Template geschrieben.
2.  **Merge:** Ein Oneshot-Systemd-Service nutzt `jq`, um das Nix-Template mit `/var/lib/nixhome/user-config.json` zu verschmelzen.
3.  **Deployment:** Das Ergebnis liegt in `/run/nixhome/config.json` (flüchtiger Speicher, immer aktuell).

### Das `nixhome-apply` CLI-Tool
Ermöglicht den schnellen Konfigurations-Reload:
*   **Logik:** Triggert den Merger-Service und führt anschließend gezielte Reloads durch (z.B. `systemctl reload caddy`).
*   **Vorteil:** Schnelle Iterationszyklen bei UI- oder Proxy-Anpassungen.

### Integration (Nix-Snippet)
```nix
systemd.services.nixhome-config-merger = {
  before = ["caddy.service" "pocket-id.service"];
  wantedBy = ["multi-user.target"];
  serviceConfig.ExecStart = mergerScript;
};
```

## 3. Reasoning Layer (History)

### [ADR-021] Hybrid Config vs. Pure Nix
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Einige Dienste benötigen dynamische Laufzeitparameter, die nicht Teil der statischen Nix-Deklaration sein sollten oder können.
*   **Entscheidung:** Nutzung einer JSON-Bridge in `/run/`.
*   **Vorteile:** Entkopplung von Deklaration und Laufzeit. Werkzeuge von Drittanbietern können den Systemstatus lesen, ohne Nix-Kenntnisse zu benötigen.
*   **Sicherheit:** Die `user-config.json` ist durch Standard-Linux-Rechte (644) geschützt, während die SSoT-Werte sicher aus Nix kommen.

---
**Sources:**
*   `00-core/config-merger.nix`
