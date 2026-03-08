# Service: Troubleshooting System Load & Rogue Processes

## 1. User Layer (KISS)
Dieses Dokument hilft dir, wenn dein Server plötzlich langsam wird oder ein Programm zu viel Rechenleistung (CPU) frisst. Wir nutzen einfache Befehle, um den Übeltäter zu finden und ihn sicher zu beenden, ohne das restliche System zu stören.

## 2. Technical Layer (Aviation-Grade)

### Analyse-Werkzeuge
1.  **Top / Htop:** Erster Überblick über CPU und RAM.
2.  **Ps:** Detailprüfung eines spezifischen Prozesses.
    *   `ps -f -p <PID>` (Zeigt Startbefehl und User).
3.  **Pgrep:** Findet Prozesse nach Namen.
    *   `pgrep -f "python"` (Listet alle Python-PIDs).

### Prozess-Eliminierung (Safe-to-Hard)
1.  **Stufe 1 (Sanft):** `kill <PID>` (Signal 15 - Erlaubt sauberes Beenden).
2.  **Stufe 2 (Harter Abbruch):** `kill -9 <PID>` (Signal 9 - Sofortiges Killen).
3.  **Stufe 3 (Massen-Kill):** `pkill -9 -f "suchbegriff"` (Löscht alle passenden Instanzen).

### Spezielles: Python Last-Analyse
Oft verursachen Hintergrund-Skripte oder KI-Agents hohe Last.
*   **Check:** `top` -> Drücke `c` (zeigt vollen Pfad des Skripts).
*   **Abhilfe:** Falls ein Prozess `pt_main_thread` (Python Thread) 99% CPU nutzt, ist meist ein hängender Loop die Ursache.

## 3. Reasoning Layer (History)

### [SRE-LEARNING] Vermeidung von blinden pkill Befehlen
Blinde Befehle wie `pkill python` können kritische Systemdienste (wie Teile der NixOS-Automation oder des Backups) unterbrechen. Daher ist das **Präzisions-Monitoring** (erst `ps`, dann gezieltes `kill`) immer dem Massen-Kill vorzuziehen.

---
**Sources:**
*   `/home/Knowledge-Pipeline/raw/_duplikate/Gemini-Python-Prozess verursacht hohe Systemlast.md`
