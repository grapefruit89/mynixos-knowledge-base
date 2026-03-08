# Service: Volatile System Logging (SSD Protection)

## 1. User Layer (KISS)
Dieses Dokument beschreibt das "Kurzzeitgedächtnis" deines Servers. Normalerweise schreiben Linux-Systeme ständig Protokolle (Logs) auf die Festplatte, was diese mit der Zeit abnutzt. Dein Server speichert alle Informationen ausschließlich im Arbeitsspeicher (RAM). Das macht das System schneller und schont deine SSD. Nach einem Neustart sind die Logs zwar weg, aber das passt perfekt zu deiner "Alles-frisch-beim-Start" Strategie.

## 2. Technical Layer (Aviation-Grade)

### Journald-Optimierung
Das Modul implementiert eine aggressive RAM-first Logging-Strategie:
*   **Speicherort:** `Storage=volatile` (Logs landen nur in `/run/log/journal`).
*   **Quotas:** Maximal 500MB RAM-Belegung, automatische Rotation bei 100MB pro Datei.
*   **Aufbewahrung:** `MaxRetentionSec=5day`.

### Debugging-Vorteile
*   **Kein Datenverlust:** Rate-Limiting ist deaktiviert (`RateLimitIntervalSec=0`), um vollständige Transparenz bei der Fehlersuche zu garantieren.
*   **Log-Level:** Speichert alles bis Stufe `debug` im RAM, zeigt aber nur `info` auf der Konsole an.

### Integration (Nix-Snippet)
```nix
services.journald.extraConfig = ''
  Storage=volatile
  RuntimeMaxUse=500M
  RateLimitIntervalSec=0
'';
```

## 3. Reasoning Layer (History)

### [ADR-025] Volatile vs. Persistent Logging
*   **Status:** Entschieden (März 2026).
*   **Kontext:** In einer Stateless-Umgebung (Root auf tmpfs) ist persistentes Logging ein logischer Bruch und verursacht unnötige IO-Last auf der System-SSD.
*   **Entscheidung:** Umstellung auf rein flüchtiges Logging.
*   **Vorteile:** Signifikante Reduzierung der Schreibzyklen (TBW) auf der SSD.
*   **Nachteil:** Logs sind nach einem Crash/Reboot nicht mehr verfügbar. 
*   **Kompensation:** Für kritische Audits sollten zukünftig wichtige Logs (z.B. Security-Events) an einen externen SRE-Collector gesendet werden.

---
**Sources:**
*   `00-core/logging.nix`
