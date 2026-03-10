# Service: TTY Boot Banner (Headless Discovery)

## 1. User Layer (KISS)
Dieses Dokument beschreibt das "Begrüßungsschild" deines Servers. Wenn du einen Monitor an deinen Server (Fujitsu Q958) anschließt, siehst du sofort nach dem Start alle wichtigen Informationen: Welche IP-Adresse der Server hat, unter welcher Web-Adresse er erreichbar ist und wie der exakte Befehl lautet, um dich von deinem Laptop aus per SSH zu verbinden. Du musst also nie wieder in deinem Router nach der IP-Adresse suchen.

## 2. Technical Layer (Aviation-Grade)

### Funktionsweise
Das Modul implementiert einen systemd-Dienst, der gezielt auf die physische Konsole schreibt:
*   **Ziel:** `/dev/tty1`.
*   **Trigger:** `after = ["network-online.target"]`.
*   **Technik:** Ein Bash-Skript extrahiert IPv4-Adressen via `iproute2` und formatiert diese mit ANSI-Farbcodes.

### Angezeigte Informationen
*   **Netzwerk:** Alle aktiven IPv4-Schnittstellen (LAN, VLAN, Tailscale).
*   **URLs:** Standard-URLs wie `nixhome.local` oder die Hostname-basierte Adresse.
*   **Management:** Kompletter SSH-Verbindungs-String inklusive User und Custom-Port.

### Integration (Nix-Snippet)
```nix
systemd.services.tty-ip-info = {
  after = ["network-online.target"];
  wantedBy = ["multi-user.target"];
  serviceConfig = {
    Type = "oneshot";
    StandardOutput = "tty";
    TTYPath = "/dev/tty1";
  };
  script = "..."; # Logik zur IP-Extraktion
};
```

## 3. Reasoning Layer (History)

### [ADR-027] Dynamic TTY Banner vs. Static MOTD
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Headless-Server werden oft ohne Tastatur/Monitor betrieben. Im Fehlerfall ist die erste Diagnose-Hürde die Erreichbarkeit.
*   **Entscheidung:** Einführung eines dynamischen Banners auf TTY1.
*   **Vorteil:** Sofortige Transparenz nach dem Bootvorgang. Da die IP-Adresse bei DHCP-Wechseln variieren kann, ist eine dynamische Anzeige einer statischen `motd` oder `issue` Datei überlegen.

---
**Sources:**
*   `00-core/tty-info.nix`
*   `00-core/configs.nix`
