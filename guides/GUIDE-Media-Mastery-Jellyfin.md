---
title: 🎬 Jellyfin Media Mastery (The 2% Standard)
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [ultra-efficient-transcoding, quicksync-mastery, low-load-streaming]
sources: [Internal Performance Audit, User Feedback]
---

# 🎬 Jellyfin: Aviation-Grade Streaming

Mit der korrekten Intel QuickSync (iHD) Integration erreichen wir eine beispiellose Effizienz auf dem Fujitsu Q958.

## ⚡ Der 2% Performance-Standard
Durch das Hardware-Mapping (\`/dev/dri/renderD128\`) wird die CPU fast vollständig entlastet.
- **Benchmark:** 4K-Transcoding verursacht lediglich ~2% CPU-Last.
- **Kapazität:** Der Tower kann problemlos >10 parallele Hardware-Transcodes bewältigen.

## ⚙️ SRE-Konfiguration
Wir erzwingen die Nutzung des \`intel-media-driver\` in der NixOS-Config (Kapitel 25), um diesen Standard zu garantieren.

## 🛡️ SRE-Monitoring
Die iGPU-Last wird separat via \`intel_gpu_top\` überwacht, da die klassische CPU-Last-Anzeige (btop/htop) die tatsächliche Transcoding-Leistung nicht widerspiegelt.