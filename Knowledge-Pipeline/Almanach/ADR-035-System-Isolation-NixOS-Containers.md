# [ADR-035]: System Isolation via NixOS Containers
# ID: [ADR-035] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wenn ein Dienst so sicher sein muss, dass er ein eigenes kleines Betriebssystem braucht, nutzen wir NixOS Containers. Es ist die "reinste" Form der Isolation auf NixOS, da sie direkt vom System (systemd) verwaltet wird.

## 2. Technical Layer
- **Technik:** `systemd-nspawn`.
- **Konfiguration:** Deklarativ in der `configuration.nix` via `containers.<name> = { ... }`.
- **Vorteil:** Der Container teilt sich den Nix-Store mit dem Host (0% Speicher-Duplizierung), hat aber eigene IP-Adressen und Dateisystem-Mounts.
- **Abgrenzung zu Bubblewrap:** Containers sind für dauerhafte Dienste; Bubblewrap für flüchtige Prozesse.

## 3. Reasoning Layer
- **Warum?** Wir vermeiden Docker/Podman-Overhead. NixOS Containers sind "native citizens".
- **Sicherheit:** Bietet echte Prozess- und Netzwerk-Isolation.

---
> [SOURCE]: https://saylesss88.github.io/ & SRE Mandat
