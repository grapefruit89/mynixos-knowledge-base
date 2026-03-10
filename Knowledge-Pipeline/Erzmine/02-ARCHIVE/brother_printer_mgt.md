# 🖨️ M7C5 Drucker-Management: Brother HL-L2445DW

Dieses Dokument enthält alle technischen Details zur Wartung, Überwachung und Beschaffung für den Brother Laserdrucker.

## 📋 Geräte-Stammdaten
- **Modell:** Brother HL-L2445DW
- **IP-Adresse:** `192.168.2.105` (Feste Zuweisung im Speedport-Router)
- **Firmware-Stand:** `MAIN 1.16`
- **⚠️ WICHTIG:** Firmware-Updates im Web-Interface auf **DEAKTIVIERT** lassen, um die Kompatibilität mit Aftermarket-Tonern nicht zu gefährden.

## 🛠️ Monitoring & API
Wir haben ein Python-Tool entwickelt, das den Drucker-Status (Toner, Trommel, Zähler) über die Weboberfläche ausliest.

- **Skript-Pfad:** `/home/moritz/Projekte/KI/local/brother_ultimate_api.py`
- **Ausführung:** `export PRINTER_PASS="XXX" && python3 brother_ultimate_api.py`
- **Versteckte Diagnose-Pfade:** 
  - `/general/status.xml` (Maschinen-Rohdaten)
  - `/general/diag.html` (Sensor-Werte)
  - `/general/model_info.html` (Detaillierte Hardware-Info)

## 🔋 Verbrauchsmaterial (Toner TN-2510XL)
Stand der Trommel am 19.02.2026: **92 %** (ca. 1.250 Seiten gedruckt).

### Toner-Empfehlungen (Aftermarket)
| Hersteller | Preis ca. | Reichweite | Einschätzung |
| :--- | :--- | :--- | :--- |
| **True Image** | 15 € | 3.000 S. | Preis-König, hohes Sparpotenzial. |
| **Logic-Seek** | **25 €** | **3.000 S.** | **Empfehlung:** Beste Balance aus Support & Preis. |
| **Ampertec** | 40 € | 3.000 S. | Made in Germany, Fokus auf Umwelt. |
| **KMP** | 45 € | 3.000 S. | Premium-Qualität (DIN-Norm). |
| **FairToner** | 60 € | 3.000 S. | Teuer, aber 7 Jahre Garantie. |

**Pro-Tipp bei Toner-Warnung:** Im Menü unter `Allgemein` -> `Toner ersetzen` auf **Fortsetzen** stellen, um die Kartusche wirklich leer zu drucken.

## 📂 Hilfsmittel
- **Okular:** Tab-Ansicht aktiviert via `kwriteconfig6`.
- **Boomaga:** Virtueller Drucker für 2x2 Layouts (installiert via DNF).
- **German-Finder:** Bookmarklet/Tampermonkey-Skript unter `/home/moritz/Projekte/KI/local/german_finder.js`.
