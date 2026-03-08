# Service: Brother Printer Management (HL-L2445DW)

## 1. User Layer (KISS)
Dieses Dokument beschreibt die Wartung deines Brother Laserdruckers. Wichtigste Regel: **Installiere niemals Firmware-Updates**, da diese nur dazu dienen, günstige Ersatztoner auszusperren. Wenn der Toner leer ist, kannst du den Drucker im Menü zwingen, trotzdem weiterzudrucken, bis die Kartusche wirklich leer ist.

## 2. Technical Layer (Aviation-Grade)

### Gerätedaten & Netzwerk
*   **Modell:** Brother HL-L2445DW
*   **IP-Adresse:** `192.168.2.105` (Static DHCP im Router).
*   **Firmware:** Lock auf Version `1.16`. Update-Check im Web-Interface deaktivieren!

### Monitoring
Ein lokales Python-Skript (`brother_ultimate_api.py`) liest den Status aus.
*   **Status-Pfade:**
    *   `/general/status.xml` (Maschinen-Rohdaten)
    *   `/general/diag.html` (Sensordaten)

### Verbrauchsmaterial (Toner TN-2510XL)
*   **Empfehlung:** Logic-Seek (ca. 25€ / 3.000 Seiten).
*   **Toner-Hack:** Im Menü unter `Allgemein` -> `Toner ersetzen` auf **Fortsetzen** stellen.

## 3. Reasoning Layer (History)

### [ARCHITECT-NOTE] Firmware-Lock
Die Entscheidung gegen Updates ist rein wirtschaftlich begründet. Die Hardware-Identität des Druckers ist stabil, neue Features durch Updates bieten keinen Mehrwert gegenüber dem Risiko, den Zugriff auf günstige Toner zu verlieren.

---
**Sources:**
*   `/home/Knowledge-Pipeline/raw/_duplikate/brother_printer_mgt.md`
