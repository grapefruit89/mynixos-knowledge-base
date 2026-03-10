# [ADR-029]: Local STT Standard (Whisper.cpp)
# ID: [ADR-029] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir implementieren eine lokale Lösung zur Umwandlung von Sprache in Text (Speech-to-Text). Dies ermöglicht es uns, Audio-Notizen oder Meetings direkt auf dem eigenen Server zu transkribieren, ohne Daten an Cloud-Anbieter zu senden und ohne laufende Kosten.

## 2. Technical Layer (Spezifikation)
- **Target:** MyNixOS Layer 60 (Apps/Tools).
- **Tool:** `pkgs.whisper-cpp` (Hochperformante C++ Portierung von OpenAI Whisper).
- **Optimierung:** Nutzt AVX2/F16C Instruktionen der Intel CPU (9. Gen) für maximale Performance ohne GPU.
- **Modelle:** Nutzung von "base" oder "small" Modellen für optimale Balance zwischen Geschwindigkeit und Genauigkeit auf 16GB RAM.

## 3. Reasoning Layer (ADR)
- **Warum Whisper.cpp?** Im Gegensatz zu "Faster-Whisper" (Python) ist dies eine reine C++ Implementierung mit minimalem Overhead. Es ist eine Single-Binary ("Aviation-Grade").
- **[REJECTED]:** Parakeet. Grund: Zu starke Bindung an NVIDIA/CUDA Hardware.
- **Effizienz:** Der Speicherbedarf ist extrem gering, der Dienst kann via Socket-Activation oder Path-Unit bei Bedarf gestartet werden.

---
> [SOURCE]: https://github.com/ggerganov/whisper.cpp
> [NUGGET-ID]: [NUGGET-AI-001]
