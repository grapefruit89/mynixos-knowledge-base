# [GUIDE]: Multiboot-Mastery via Ventoy
# ID: [NUGGET-SRE-006] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision
Um maximale Flexibilität beim Booten von Live-Systemen (NixOS, Nobara, WinPE) zu haben, nutzen wir Ventoy. Dies erlaubt das Starten von ISOs direkt vom Dateisystem ohne permanentes Flashen.

## 2. Installation (CLI-Weg)
```bash
# 1. Neueste Version beziehen
VERSION=$(curl -s https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+[^"]*')
URL="https://github.com/ventoy/Ventoy/releases/download/v${VERSION}/ventoy-${VERSION}-linux.tar.gz"

# 2. Download & Installation auf Target (sdX anpassen!)
curl -L $URL -o ventoy.tar.gz && tar -xzvf ventoy.tar.gz
cd ventoy-${VERSION}
sudo ./Ventoy2Disk.sh -i /dev/sdX
```

## 3. Best Practices
- **Dateisystem:** ExFAT nutzen für maximale Kompatibilität.
- **Persistence:** Für NixOS-ISOs können spezielle Persistence-Dateien via Ventoy angelegt werden.
- **Sicherheit:** Den Stick verschlüsseln, falls sensible private Keys darauf liegen.

---
> [SOURCE]: Erzmine/02-ARCHIVE/Gemini-Mehrere Betriebssysteme auf USB-Stick.md
