---
id: GUIDE-Modular-Media-Stack-Factory
title: Modular Media Stack Factory Architecture
status: accepted
date: 2026-03-10
tags: [nixos, factory-pattern, media-stack, servarr, hardening]
---

# GUIDE: Modular Media Stack Factory Architecture

## 1. USER LAYER (KISS)
Anstatt für jeden Media-Service (Sonarr, Radarr, Lidarr, etc.) den gleichen Code für Benutzer, Gruppen, Dateiberechtigungen und Sicherheitseinstellungen zu kopieren, nutzen wir eine "Fabrik" (Factory). In dieser Fabrik definieren wir einmal den Standard-Sicherheitsstandard (Hardening) und wie die Dienste konfiguriert werden. Neue Dienste können dann mit nur wenigen Zeilen Code erstellt werden, die alle automatisch sicher und konsistent sind.

## 2. TECHNICAL LAYER (Specification)

### Das Factory-Pattern (`_servarr-factory.nix`)
Die Factory stellt Funktionen bereit, die in den einzelnen Service-Modulen aufgerufen werden.

#### Zentrale Funktionen:
- **`mkServarrHardening`:** Ein vordefiniertes Set an Systemd-Härtungsparametern (z.B. `NoNewPrivileges`, `PrivateTmp`, `ProtectKernelLogs`), das für alle Dienste gilt.
- **`mkServarrSettingsEnvVars`:** Konvertiert Nix-Konfigurations-Attribute (z.B. `server.port = 8989`) automatisch in Umgebungsvariablen (`SONARR__SERVER__PORT = 8989`), die von den Servarr-Diensten beim Start eingelesen werden.
- **`mkServarrUserGroup`:** Erstellt automatisch Systembenutzer und Gruppen mit den richtigen Berechtigungen für den jeweiligen Dienst.

#### Beispiel für einen neuen Dienst (z.B. `sonarr.nix`):
```nix
{ config, lib, pkgs, ... }:
let
  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
in
{
  # Nutzt die Factory-Funktionen für konsistente Konfiguration
  options.services.sonarr = {
    settings = factory.mkServarrSettingsOptions "sonarr" 8989;
    # ... weitere Optionen
  };
  
  config = lib.mkIf config.services.sonarr.enable {
    systemd.services.sonarr = {
      serviceConfig = factory.mkServarrHardening // {
        ExecStart = "${pkgs.sonarr}/bin/Sonarr -nobrowser -data=${config.services.sonarr.stateDir}";
      };
      environment = factory.mkServarrSettingsEnvVars "sonarr" config.services.sonarr.settings;
    };
  };
}
```

## 3. REASONING LAYER (ADR)

### Warum dieses Factory-Pattern?
- **DRY (Don	 Repeat Yourself):** Reduziert den Code um ca. 60-70% pro Service.
- **Sicherheits-Garantie:** Wenn eine neue Härtungs-Maßnahme in der Factory hinzugefügt wird, profitieren sofort alle Media-Services davon (Zentrales Patching).
- **Konsistenz:** Alle Pfade, Benutzer und Ports folgen demselben Schema (NMS v4.2 Standard).

### Warum Environment-Variablen statt INI-Files?
Servarr-Dienste (C#/.NET) lassen sich hervorragend über Umgebungsvariablen steuern. Dies vermeidet das manuelle Schreiben von XML- oder INI-Dateien über Nix, was fehleranfällig sein kann. Die Factory nutzt hierbei rekursive Nix-Filter, um die Struktur sauber zu mappen.

### Alternativen (Verworfen):
- **Native NixOS Module:** Oft zu unflexibel oder unvollständig gehärtet.
- **Docker-Compose:** Bietet nicht die granulare System-Integration (systemd hardening) und Reproduzierbarkeit von nativem NixOS.

---
> [ARCHITECT-NOTE]: Extrahiert aus mynixos/40-media/service-media-_servarr-factory.nix (v2026.03.02)
