# Service: OliveTin Control Panel (SRE Operations)

## 1. User Layer (KISS)
Dieses Dokument beschreibt das "Armaturenbrett" deines Servers. Über eine einfache Webseite (OliveTin) kannst du wichtige Aufgaben per Knopfdruck erledigen: Neue Sicherheits-Zertifikate erstellen, Passwörter verschlüsseln oder das gesamte System aktualisieren. Der Clou: Das Programm schläft die meiste Zeit und wacht erst auf, wenn du die Seite aufrufst – das spart Strom und Rechenleistung.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Ressourcen-Schonung
Das Control Panel nutzt **Socket Activation**:
*   **Socket:** `systemd.sockets.olivetin` lauscht permanent auf dem konfigurierten Port.
*   **Service:** `systemd.services.olivetin` wird erst bei Zugriff instantan gestartet.
*   **Vorteil:** Null RAM-Verbrauch im Leerlauf.

### Definierte Web-Aktionen
1.  **SOPS Injection:** Hinzufügen von verschlüsselten Secrets via Web-Maske.
2.  **mTLS Provisioning:** Triggert den `mtls-generator.sh` für neue Geräte.
3.  **Aviation-Grade Rebuild:** Führt `nixos-rebuild` aus und leitet die Ausgabe durch den `nix-output-monitor` (NOM) für eine saubere Visualisierung des Fortschritts.

### SRE-Hardening (Sudo-Regeln)
Der User `olivetin` darf ausschließlich folgende Befehle ohne Passwort ausführen:
*   `/run/current-system/sw/bin/nixos-rebuild`
*   `/etc/nixos/00-core/scripts/mtls-generator.sh`

### Integration (Nix-Snippet)
```nix
systemd.sockets.olivetin.listenStreams = [ (toString config.my.ports.olivetin) ];
services.olivetin = {
  enable = true;
  settings.actions = [ ... ]; # Aktions-Definitionen siehe oben
};
```

## 3. Reasoning Layer (History)

### [ADR-029] Web-Actions vs. SSH-Only Management
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Management-Aufgaben von mobilen Endgeräten via SSH sind mühsam.
*   **Entscheidung:** Einführung von OliveTin als sichere Web-Bridge.
*   **Vorteile:** Abstraktion komplexer CLI-Befehle in einfache Formulare. Durch mTLS und SSO (Pocket-ID) ist der Zugriff auf das Control-Panel doppelt abgesichert.
*   **SRE-Aspekt:** Die Nutzung von Socket-Activation passt zum "Efficient-Server" Design und reduziert die Hintergrund-Last.

---
**Sources:**
*   `30-automation/service-app-olivetin.nix`
*   `30-automation/automation.nix`
*   `00-core/lib-helpers.nix`
