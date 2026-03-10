# [GUIDE]: Automatischer STT-Workflow (Whisper)
# ID: [NUGGET-AI-002] | Status: ACTIVE | Stand: 10.03.2026

## 1. Das "Silent Translator" Prinzip
Wir nutzen den `systemd.path` Geist, um Audio-Dateien vollautomatisch zu verarbeiten.

## 2. Der Workflow
1. **Drop:** Du lädst eine `.mp3` oder `.wav` Datei in den Ordner `/mnt/storage/transcribe/inbox`.
2. **Trigger:** `systemd.path` erkennt die neue Datei und startet `whisper-cpp.service`.
3. **Process:** Whisper wandelt das Audio in eine `.txt` Datei im Ordner `../results` um.
4. **Notify:** Nach Abschluss sendet der Dienst eine Erfolgsmeldung via `ntfy` (ADR-025).

## 3. CLI-Anwendung (Manuell)
Falls du manuell transkribieren willst:
```bash
whisper-cpp -m /var/lib/whisper/models/ggml-base.bin -f audio.wav -otxt
```

---
> [ARCHITECT-NOTE]: Die Path-Unit sorgt für 0% CPU Last, solange keine Datei zur Bearbeitung ansteht.
