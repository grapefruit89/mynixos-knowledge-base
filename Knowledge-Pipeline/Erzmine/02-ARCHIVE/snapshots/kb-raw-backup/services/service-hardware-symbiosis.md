# Service: Hardware Symbiosis (Auto-Discovery & Microcode)

## 1. User Layer (KISS)
Dieses Dokument beschreibt das "Sinnesorgan" deines Servers. Es erkennt automatisch, welche Hardware verbaut ist (z.B. Intel oder AMD Prozessor) und sorgt dafür, dass die passenden Sicherheits-Updates (Microcode) geladen werden. Zudem warnt dich das System proaktiv, wenn der Arbeitsspeicher zu knapp wird oder wenn deine Hardware-Informationen veraltet sind.

## 2. Technical Layer (Aviation-Grade)

### Hardware-Management
Das Modul abstrahiert die CPU-spezifische Konfiguration:
*   **Microcode:** Automatische Aktivierung basierend auf `config.my.configs.hardware.cpuType`.
*   **Validierung:** System-Warnings bei RAM-Bestand < 4GB.

### Operative Tools
*   **`nixhome-detect-hw`:** CLI-Tool zur Erfassung der aktuellen Hardware-Parameter (RAM, etc.) im JSON-Format.
*   **Age Check:** Ein automatischer Check prüft die Aktualität des Hardware-Profils (`user-config.json`) und meldet Drift nach 30 Tagen.

### Integration (Nix-Snippet)
```nix
hardware.cpu.intel.updateMicrocode = lib.mkIf (cpuType == "intel") config.hardware.enableRedistributableFirmware;
hardware.cpu.amd.updateMicrocode = lib.mkIf (cpuType == "amd") config.hardware.enableRedistributableFirmware;
```

## 3. Reasoning Layer (History)

### [ADR-022] Abstract Hardware Layer (Symbiosis)
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Die direkte Hardware-Konfiguration in `configuration.nix` macht das System unportabel.
*   **Entscheidung:** Einführung des Symbiosis-Moduls, das nur auf SSoT-Werten operiert.
*   **Vorteil:** Ein Host-Wechsel (z.B. von Q958 auf einen AMD-basierten Server) erfordert nur die Änderung eines einzigen Wortes (`cpuType = "amd"`) in der zentralen SSoT, woraufhin alle Treiber und Optimierungen automatisch umschalten.

---
**Sources:**
*   `00-core/symbiosis.nix`
*   `00-core/configs.nix`
