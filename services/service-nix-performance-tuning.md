# Service: Nix Performance & Binary-Only Policy

## 1. User Layer (KISS)
Dieses Dokument beschreibt die "Abnehmdiät" deines Servers. Wir verbieten dem Server strengstens, Programme selbst zu bauen (zu kompilieren). Stattdessen lädt er alles fix und fertig vorbereitet aus dem Internet herunter. Das spart massiv Zeit bei Updates, schont deinen Prozessor und verlängert das Leben deiner SSD. Alles passiert im Hintergrund, während du den Server für andere Dinge nutzt.

## 2. Technical Layer (Aviation-Grade)

### Binary-Cache & Enforcement
Das Modul erzwingt die Nutzung von Binär-Caches und verhindert lokale Builds:
*   **Caches:** `cache.nixos.org` (Offiziell) und `nix-community.cachix.org` (Community Tools).
*   **Binary-Lock:** `max-jobs = 0` (Verbot lokaler Kompilierung).
*   **Optimierung:** `auto-optimise-store = true` (Zusammenführung identischer Dateien im Store).

### SRE Daemon-Tuning
*   **Scheduling:** Der Nix-Daemon läuft mit `idle` Priorität für CPU und I/O, um laufende Dienste (Jellyfin, HA) niemals zu stören.
*   **Maintenance:** Wöchentliche Garbage Collection (`nix.gc`) für Generationen > 14 Tage.

### Integration (Nix-Snippet)
```nix
nix.settings = {
  max-jobs = 0;
  builders-use-substitutes = true;
  experimental-features = ["nix-command" "flakes" "cgroups"];
};
nix.daemonCPUSchedPolicy = "idle";
```

## 3. Reasoning Layer (History)

### [ADR-026] Binary-Only vs. Custom Compilation
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Auf einem Heimserver (Fujitsu Q958 mit i3-9100) führt das Kompilieren großer Pakete zu hoher Systemlast und Hitzeentwicklung.
*   **Entscheidung:** Strikte Binary-Only Policy.
*   **Vorteil:** Vorhersehbare Deployment-Zeiten und minimaler Hardware-Verschleiß.
*   **Risiko:** Pakete, die nicht im Cache liegen, können nicht installiert werden. Dies wird durch die Einbindung des `nix-community` Caches weitgehend abgefedert.

---
**Sources:**
*   `00-core/nix-tuning.nix`
*   `00-core/configs.nix`
