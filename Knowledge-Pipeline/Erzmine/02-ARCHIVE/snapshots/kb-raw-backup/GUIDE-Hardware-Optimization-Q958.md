---
id: GUIDE-Hardware-Optimization-Q958
title: Hardware Optimization Guide (Fujitsu Q958)
status: accepted
date: 2026-03-10
tags: [hardware, intel, q958, gpu, quicksync, va-api]
---

# GUIDE: Hardware Optimization (Fujitsu Q958)

## 1. USER LAYER (KISS)
Der Fujitsu Q958 ist ein kompakter Desktop-PC mit einer Intel i3-9100 CPU. In dieser Anleitung optimieren wir die integrierte Grafikkarte (UHD 630) für maximale Performance bei Video-Transcoding (z.B. für Jellyfin oder Handbrake) und verringern den Stromverbrauch durch Kernel-Tweaks. Wir schalten spezielle Funktionen der Grafikkarte frei (GuC/HuC), die standardmäßig oft inaktiv sind.

## 2. TECHNICAL LAYER (Specification)

### Grafik & Transcoding (Intel QuickSync / QSV)
Die Optimierung basiert auf dem `i915` Kernel-Treiber. Wir setzen spezifische Parameter, um Hardware-Beschleunigung vollständig zu aktivieren.

#### Kernel-Parameter (NixOS):
```nix
boot.kernelParams = [
  "i915.enable_guc=3"  # Aktiviert Graphics Microcode (GuC) v3
  "i915.enable_fbc=1"  # Framebuffer Compression (Stromersparnis)
  "i915.enable_psr=1"  # Panel Self Refresh
];
```

#### Benötigte Pakete (Nixpkgs Hardware Standard):
Für VA-API und OpenCL sind folgende Treiber essenziell:
- `intel-media-driver` (iHD Driver für moderne Intel GPUs)
- `intel-compute-runtime` (OpenCL Support)
- `vpl-gpu-rt` (OneVPL für Video-Verarbeitung)

#### User-Berechtigungen:
Der Hauptbenutzer muss Mitglied der Gruppen `video` und `render` sein, um Zugriff auf die GPU-Devices (`/dev/dri/renderD128`) zu haben.

### Monitoring-Tools
Um die Auslastung der GPU zu prüfen, nutzen wir:
- `intel-gpu-tools` (Befehl: `intel_gpu_top`)
- `libva-utils` (Befehl: `vainfo`)

## 3. REASONING LAYER (ADR)

### Warum GuC/HuC aktivieren?
GuC (Graphics Microcode) übernimmt Aufgaben von der CPU, was die Effizienz beim Video-Streaming steigert. HuC (Heuristic Microcode) verbessert die Video-Kodierung zusätzlich. Ohne diese Parameter (standardmäßig inaktiv) wird die GPU nicht optimal ausgelastet.

### Warum LIBVA_DRIVER_NAME = "iHD"?
Es gibt zwei Intel-Treiber (`i965` und `iHD`). Der `iHD`-Treiber ist der moderne Nachfolger für CPUs ab der 8. Generation (Coffee Lake), zu der der i3-9100 gehört. Er bietet besseren Support für HEVC und VP9 Codecs.

### Alternativen (Verworfen):
- **Legacy i965 Treiber:** Zu langsam und schlechter Support für moderne Codecs.
- **Generic VA-API:** Bietet nicht die spezialisierten QuickSync-Features der Intel-Plattform.

---
> [ARCHITECT-NOTE]: Extrahiert aus mynixos/00-core/host-q958-hardware-profile.nix (v2026.03.03)
