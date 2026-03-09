---
title: 🚀 Hardware Acceleration Deep-Dive (The Anti-Stuttering Protocol)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [quicksync-mastery, low-latency-streaming, 4k-transcoding]
sources: [Intel Media Driver Docs, Jellyfin Hardware Acceleration Guide]
---

# 🚀 Das Anti-Stuttering Protokoll

Wenn Medien ruckeln, ist das ein Versagen der Hardware-Abstraktion. Wir lösen dies durch direkten GPU-Zugriff.

## 🏛️ 1. Die Treiber-Wahl (Layer 00-core)
Für den i3-9100 (Coffee Lake) ist der \`intel-media-driver\` (iHD) zwingend.
- **NixOS Config:**
\`\`\`nix
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver # Der moderne iHD Treiber
    intel-vaapi-driver # Fallback für ältere Apps
    vaapiVdpau
    libvdpau-va-gl
  ];
};
\`\`\`

## 🛡️ 2. Jellyfin Permission-Fix (Layer 40-media)
Ruckler entstehen oft durch fehlende Leserechte auf dem Render-Node.
- **Lösung:** Der Jellyfin-User muss in der Gruppe \`render\` und \`video\` sein.
- **Systemd-Hardening:**
\`\`\`nix
systemd.services.jellyfin.serviceConfig = {
  DeviceAllow = [ "/dev/dri/renderD128 rw" ];
  PrivateDevices = false; # Muss für GPU-Zugriff false sein
};
\`\`\`

## ⚡ 3. Die "Smooth-Stream" Settings (In Jellyfin)
In der Admin-Konsole unter "Transcoding":
1. **Hardware-Beschleunigung:** Intel QuickSync (QSV) wählen.
2. **Low-Power Encoding:** Aktivieren (spart massiv Energie).
3. **Hardware-Decodierung:** Alles anhaken (H264, HEVC, MPEG2, VC1, VP8, VP9).

## 📊 Performance-Check
Führe \`intel_gpu_top\` (aus dem Paket \`intel-gpu-tools\`) aus. Wenn der Balken bei "Video" ausschlägt und die CPU bei ~2% bleibt, ist das Ziel erreicht.