# [GUIDE]: Systemd Hardening Baselines & Geister
# ID: [NUGGET-SRE-009] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & Prinzipien
Auf einem Aviation-Grade System ist `systemd` nicht nur ein Init-System, sondern unser primärer SRE-Orchestrator. Wir verzichten auf externe Supervisor (Docker, SupervisorD) und nutzen die tiefgreifenden Linux-Kernel-Features, die `systemd` exponiert. 

## 2. Die vier Geister von systemd

### 👻 1. Socket Activation (RAM-Saver)
Dienste werden erst gestartet, wenn Traffic auf ihrem Port (Socket) ankommt. Sie schlafen im RAM, bis sie gerufen werden.

**Die Klassifizierung (Welche Dienste schlafen dürfen):**
*   🟢 **DEFINITIV SCHLAFEN (Neben-Tools):**
    *   `Filebrowser` (Wird nur manuell genutzt)
    *   `Readeck` / `Linkding` (Bookmarks, punktuelle Nutzung)
    *   `Scrutiny` Web-Dashboard (Der Collector-Cron läuft separat, das UI braucht kein 24/7 RAM)
    *   `Miniflux` (RSS-Reader, nur aktiv, wenn du liest)
    *   `Cockpit` (Admin-Dashboard)
*   🟡 **VIELLEICHT SCHLAFEN (Evaluierung):**
    *   `Forgejo`: Ein lokaler Git-Server kann schlafen. Wenn jedoch CI-Runner (Actions) polen, wecken sie ihn ständig auf.
    *   `Vaultwarden`: Hat einen winzigen Footprint (Rust). Kann schlafen, aber ständige Socket-Starts könnten beim schnellen Auto-Fill minimal stören.
*   🔴 **NICHT SCHLAFEN (Kritischer Pfad):**
    *   `Caddy` (Ingress-Proxy muss immer sofort antworten)
    *   `Valkey` (In-Memory Cache)
    *   `Pocket-ID` (SSO Provider)
    *   `Jellyfin` / `Plex` (Lange Startzeiten, Streaming-Latenz)

**Code-Snippet (NixOS Socket):**
```nix
systemd.sockets."mein-service" = {
  wantedBy = [ "sockets.target" ];
  listenStreams = [ "127.0.0.1:8080" ];
};
systemd.services."mein-service" = {
  wantedBy = lib.mkForce []; # Entfernt den Autostart beim Booten
  requires = [ "mein-service.socket" ];
};
```

### 👻 2. Path Units (Event-Trigger statt Timers)
Anstatt (wie bei Cron) alle X Minuten ein Skript auszuführen, um zu schauen ob sich etwas verändert hat, lauscht `systemd` via Inotify auf das Dateisystem. Das spart CPU-Zyklen und reagiert in Echtzeit.

**Beispiel: Timer vs. Path Unit**
*   **[DEPRECATED] Der alte Timer-Weg:** `boot-space-monitor` läuft alle 10 Minuten und checkt `/boot`.
*   **[NEW] Der Path-Weg:** Der Monitor läuft *nur* dann, wenn sich in `/boot` tatsächlich eine Datei ändert (z.B. beim `nixos-rebuild`).

**Code-Snippet (NixOS Path Unit):**
```nix
systemd.paths."boot-monitor" = {
  wantedBy = [ "multi-user.target" ];
  pathConfig = {
    PathChanged = "/boot";
  };
};
systemd.services."boot-monitor" = {
  script = "df -h /boot | grep -q '100%' && ntfy send 'BOOT VOLL!'";
  # Kein wantedBy hier, da die Path-Unit den Start triggert!
};
```

### 👻 3. Hardening & Sandboxing
Dienste werden in isolierte Namensräume gesperrt. Dies ist unser nativer Ersatz für Docker-Isolation.

**Code-Snippet (Das "Aviation-Grade" Gefängnis):**
```nix
systemd.services."gefaehrlicher-service".serviceConfig = {
  ProtectSystem = "strict";       # Dateisystem ist Read-Only (außer ReadWritePaths)
  ProtectHome = true;             # Kein Zugriff auf /home (verhindert Key-Stealing)
  PrivateTmp = true;              # Eigener /tmp Mount
  PrivateDevices = true;          # Keine /dev/sd* Sichtbarkeit
  NoNewPrivileges = true;         # Verhindert SUID-Eskalation (chmod +s Hack)
  CapabilityBoundingSet = "";     # Entfernt ALLE Linux Capabilities (auch wenn der Prozess Root ist)
  RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ]; # Darf z.B. kein Bluetooth sprechen
};
```

### 👻 4. Watchdog & Auto-Healing
Automatische Überwachung auf Deadlocks für kritische Infrastruktur (z.B. Caddy, Valkey).

**Code-Snippet:**
```nix
systemd.services."mein-service".serviceConfig = {
  WatchdogSec = "30s";
  Restart = "on-watchdog";
};
```

## 3. Integration in mynixos
Diese Baselines werden schrittweise in der `Werkstatt` angewendet. Timers werden, wo sinnvoll, durch Path-Units abgelöst. Das Sandboxing wird auf alle Services angewendet, die potenziell mit dem Internet kommunizieren.
