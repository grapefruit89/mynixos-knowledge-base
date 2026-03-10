# 🔍 NIXHOME SRE-AUDIT — Community-Konformitäts-Analyse
## NMS v2.3 gegen nixpkgs-Goldstandard

Stand: 2026-03-02 | Auditor: Senior SRE / NixOS Community Research

---

> **Vorab-Klarstellung:** Das ist ein ehrlicher Befund.
> Gut durchdachte Eigenarchitektur, aber an drei entscheidenden Stellen
> löst du Probleme selbst, die die Community bereits besser gelöst hat.

---

## BEFUND-TABELLE

### 1 — Modul-Design: Layer-Architektur vs. nixpkgs-Modul-Pattern

| | |
|---|---|
| **Was du machst** | Flat-File-Sammlung pro Layer. Jede `.nix`-Datei definiert Services direkt ohne `options`/`config`-Wrapper. Kein `mkEnableOption`. Ein Layer = ein Ordner = Import-Liste. |
| **nixpkgs-Standard** | Jedes offizielle Modul hat `options.services.<name>.enable = mkEnableOption "..."` + `config = mkIf cfg.enable { ... }`. Das macht Module **bedingt aktivierbar** ohne sie aus der Import-Liste zu entfernen. |
| **Der konkrete Gap** | Wenn du einen Service deaktivieren willst, muss du ihn aus `_imports.nix` oder `flake.nix` auskommentieren. In nixpkgs setzt du einfach `services.vaultwarden.enable = false`. Dein System hat keine native Enable/Disable-Semantik. |
| **Ist das schlimm?** | Für ein Single-Host-Homelab: nein, tolerierbar. Für mehrere Hosts oder Staging/Prod-Umgebungen: ja, echtes Problem. |
| **Action-Item** | Wrap deine Module in `mkEnableOption`-Pattern. Minimal-Aufwand für großen Gewinn: `my.services.vaultwarden.enable = true` in `registry.nix` statt Datei aus Import rausschmeißen. Dein `registry.nix` ist schon fast da — aber es muss in die Module integriert sein, nicht nur als Flag-Datei existieren. |

---

### 2 — Security & Sandboxing: systemd Hardening

| | |
|---|---|
| **Was du machst** | `ProtectSystem = "strict"`, `SystemCallFilter`, `PrivateDevices`, `NoNewPrivileges`. Das ist bereits über dem nixpkgs-Durchschnitt. Viele offizielle Module haben bis 2025 kaum Sandboxing. |
| **nixpkgs-Standard** | Es gibt seit 2025 ein aktives Tracking-Issue (#377827) das Module systematisch härtet. Der Standard pro Modul ist: `systemd-analyze security <service>` laufen lassen und Score unter 4.0 bringen. Die Community unterscheidet: **pro-Service Hardening** (dein Ansatz) vs. **generisches Sandbox-Modul** (wurde in PR #87661 diskutiert aber nie gemergt, weil zu riskant). |
| **Der konkrete Gap** | Du nutzt wahrscheinlich `PrivateDevices = true` auch für Services die `/dev/dri` brauchen (Jellyfin). Das bricht Hardware-Transcoding still und heimlich. Jellyfin braucht zwingend `PrivateDevices = false` + explizite `DeviceAllow`-Regeln. Außerdem: kein `MemoryDenyWriteExecute` (JVM-Prozesse wie Jellyfin brauchen JIT → Exception nötig). |
| **Ist das schlimm?** | `PrivateDevices`-Konflikt mit GPU-Zugriff ist ein echter Bug, kein Style-Problem. Alles andere ist Best-Practice-Delta. |
| **Action-Item** | Für GPU-Services (`jellyfin`, `netdata` mit GPU-Metriken): `PrivateDevices = false` + `DeviceAllow = [ "char-drm rw" "char-dri rw" ]`. Template: `systemd-analyze security jellyfin.service` auf dem Live-System ausführen. Ziel-Score: < 4.0. Community-Referenz: [Chrony-PR #104944](https://github.com/NixOS/nixpkgs/pull/104944) als Vorlage für korrektes Hardening-Pattern. |

---

### 3 — SSOT-Integrität: NMS-Meta-Header über 650 Dokumente

| | |
|---|---|
| **Was du machst** | Eigenes ID-Schema (`NIXH-40-JELLYFIN-001`), YAML-Header in `.nix`-Kommentaren, bidirektionale Sync-Skripte `.nix` ↔ `.md`. Isomorphie-Versprechen über Bash-Automation. |
| **nixpkgs-Standard** | nixpkgs hat **kein vergleichbares Konzept** für Homelab-Dokumentation. Das ist dein eigener Anwendungsfall. Die Community nutzt für Modul-Metadaten: `meta.doc` (Markdown-String im Modul), `meta.maintainers`, `meta.platforms` — aber nur für nixpkgs-Packages, nicht für private Homelab-Konfigurationen. |
| **Ehrliche Bewertung** | Das ist **nicht over-engineered** — es ist der richtige Ansatz für ein dokumentationsgetriebenes Homelab. ABER: Das Bash-Sync-Skript ist der schwächste Punkt. `grep -oP` auf YAML in Nix-Kommentaren ist fragil. Ein Regex-Fehler und dein gesamter Header-State ist inkonsistent ohne es zu merken. |
| **Der konkrete Gap** | Die Community würde das mit `nix eval` lösen: NMS-Metadaten direkt als Nix-Attribut (`meta.nms`) im Modul definieren, dann per `nix eval .#nixosConfigurations.q958.config.meta.nms` maschinell auslesen. Keine Regex, kein grep — reines Nix. |
| **Action-Item** | Metadaten aus Kommentar-Block in echtes Nix-Attribut migrieren (Beispiel unten). Sync-Skript wird dann trivial: `nix eval --json .#meta.allModules | jq ...` statt fragiles grep. Wissen geht dabei **nicht verloren** — du bekommst sogar mehr: Nix-Typsystem prüft die Metadaten beim Build. |

**Konkretes Beispiel — Meta als Nix-Attribut:**
```nix
{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-40-MEDIA-001";
    title = "Jellyfin Media Server";
    layer = 40;
    nixpkgs.category = "servers/media";
    capabilities = [ "gpu/intel-qsv" "caddy/reverse-proxy" ];
    resources.port = 20096;
  };
in
{
  # Meta ist jetzt ein echter Nix-Wert — querybar via nix eval
  options.my.meta.jellyfin = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for jellyfin module";
  };

  config = lib.mkIf config.my.services.jellyfin.enable {
    # ... eigentlicher Service-Code
  };
}
```

---

### 4 — Hardware-Abstraktion: Intel QSV / UHD 630 / vpl-gpu-rt

| | |
|---|---|
| **Was du machst** | `vpl-gpu-rt` in `hardware.graphics.extraPackages` + `LIBVA_DRIVER_NAME = "iHD"`. Das ist laut NixOS-Wiki der empfohlene Weg. |
| **nixpkgs-Standard / offizielle Wiki-Empfehlung** | Für UHD 630 (8./9. Gen, Coffee Lake): `intel-media-driver` (VAAPI/iHD) + `vpl-gpu-rt` (QSV). Das ist korrekt für Coffee Lake. **Achtung:** `vpl-gpu-rt` ist primär für Gen 12 (Alder Lake+) optimiert — für UHD 630 (Gen 9.5) ist es nutzbar aber `intel-media-driver` alleine für VAAPI ist der eigentliche Treiber. QSV auf UHD 630 funktioniert, ist aber laut Jellyfin-Docs "Mainstream"-Tier, nicht "High Performance". |
| **Der kritische Befund** | Auf NixOS 25.11 ist VPL-Support in FFmpeg seit [diesem PR](https://wiki.nixos.org/wiki/Jellyfin) standardmäßig aktiviert. Das Overlay das du möglicherweise aus alten Guides hast (`withVpl = true, withMfx = false`) ist auf 25.11 **nicht mehr nötig** und kann Konflikte verursachen. |
| **Warnung UHD 630 spezifisch** | Coffee Lake (UHD 630) verliert laut Jellyfin-Dokumentation mittelfristig QSV-Support auf Linux, weil Intel Media SDK deprecated ist und VPL den alten MFX-Pfad für Gen 9.5 nicht vollständig ersetzt. VAAPI bleibt als Fallback funktional. Prüfe mit: `vainfo --display drm --device /dev/dri/renderD128` |
| **Action-Item** | Konfiguration vereinfachen: Nur `intel-media-driver` (VAAPI) + `vpl-gpu-rt` (QSV) + `intel-compute-runtime` (OpenCL für Tonemapping). `intel-ocl` und `intel-media-sdk` entfernen — beide deprecated. Kein Overlay auf 25.11 nötig. Verifiziere mit `intel_gpu_top` während Jellyfin transkodiert. |

**Empfohlene minimale 25.11-Konfiguration für UHD 630:**
```nix
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver    # VAAPI (iHD) — primärer Treiber für UHD 630
    vpl-gpu-rt            # QSV via OneVPL — funktioniert auf Coffee Lake
    intel-compute-runtime # OpenCL — für HDR Tonemapping in Jellyfin
    # ENTFERNEN: intel-ocl (legacy), intel-media-sdk (deprecated)
  ];
};

environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

# Jellyfin: PrivateDevices MUSS false sein für GPU-Zugriff
systemd.services.jellyfin.serviceConfig = {
  PrivateDevices = false;  # GPU-Zugriff
  DeviceAllow = [
    "char-drm rw"
    "char-dri rw"
  ];
};
```

---

### 5 — Flake-Struktur: inputs.follows

| | |
|---|---|
| **Was du machst** | Pure Flakes mit `nixpkgs-25.11`. (Unklar ob `inputs.follows` überall gesetzt ist.) |
| **nixpkgs-Standard** | `inputs.nixpkgs.follows = "nixpkgs"` bei JEDEM Input der nixpkgs nutzt. Ohne das: mehrere nixpkgs-Versionen im System → doppelte Binaries, mögliche ABI-Konflikte. home-manager und sops-nix sind die häufigsten Vergessenen. |
| **Action-Item** | `nix flake info` ausführen. Wenn unter "inputs" mehr als ein nixpkgs auftaucht → `follows` fehlt irgendwo. Minimum: `home-manager.inputs.nixpkgs.follows = "nixpkgs"` und `sops-nix.inputs.nixpkgs.follows = "nixpkgs"`. |

---

### 6 — Module-Design: registry.nix als Feature-Flag-System

| | |
|---|---|
| **Was du machst** | `registry.nix` als zentrale Enable/Disable-Datei. |
| **nixpkgs-Standard** | Das wird in der Community als "Import-All + Enable"-Pattern bezeichnet. Ein bekannter NixOS-Community-Beitrag (kobimedrish.com, 2025) beschreibt exakt dieses Pattern als Best Practice für Multi-Host-Setups. Du bist auf dem richtigen Weg. |
| **Der Gap** | Dein `registry.nix` ist vermutlich eine simple Attribut-Datei. Das Community-Pattern ist strikter: Jede Flag in `registry.nix` muss einem `mkEnableOption` in einem Modul entsprechen. Sonst gibt es keine Build-Zeit-Prüfung ob die Flag irgendwo ausgewertet wird. |
| **Action-Item** | Pro Service: `options.my.services.<name>.enable = lib.mkEnableOption "<name>"` ins Modul, `my.services.<name>.enable = true` in `registry.nix`. Dann: `nix flake check` prüft ob alle Optionen bekannt sind. |

---

## GESAMTBEWERTUNG

```
Bereich                   Dein Stand    Community-Standard    Delta
─────────────────────────────────────────────────────────────────────
Layer-Semantik            ★★★★☆         ★★★★★                 mkEnableOption fehlt
Systemd Sandboxing        ★★★★☆         ★★★☆☆                 DU bist über Standard!
                                                               (GPU-Exception beachten)
SSOT/Metadaten            ★★★☆☆         N/A (eigener Use)     Regex → nix eval
Hardware / QSV            ★★★★☆         ★★★★★                 Overlay entfernen
Flake-Struktur            ★★★★☆         ★★★★★                 follows prüfen
Module Options            ★★☆☆☆         ★★★★★                 kein mkEnableOption
─────────────────────────────────────────────────────────────────────
Gesamt                    ★★★★☆   Solide, 2 echte Lücken, 1 Bug
```

### Die 2 echten Lücken (solltest du fixen):

**Lücke 1: Kein `mkEnableOption` in Modulen**
Das ist kein Stil-Problem. Ohne das kannst du keine Module conditional aktivieren,
keine Profile bauen (Server-Profile vs. Minimal-Profil), keine Tests schreiben.

**Lücke 2: `PrivateDevices = true` bei GPU-Services**
Das ist ein potentieller stiller Bug. Jellyfin startet, aber GPU wird nicht genutzt.
Prüfen mit: `systemctl status jellyfin` und `intel_gpu_top` gleichzeitig.

### Die 1 Sache die gut ist und bleiben soll:

Dein Sandboxing-Level ist **über** dem nixpkgs-Community-Durchschnitt.
Das Tracking-Issue #377827 zeigt: die meisten NixOS-Module haben kaum Hardening.
Du hast already mehr als die meisten offiziellen Module. Nicht zurückrudern.

---

## PRIORITÄTS-LISTE

```
SOFORT (potentieller Bug):
  [ ] PrivateDevices-Konflikt bei Jellyfin prüfen
  [ ] intel-media-sdk und intel-ocl aus extraPackages entfernen (deprecated)

KURZFRISTIG (Architektur-Sauberkeit):
  [ ] mkEnableOption in alle Service-Module einbauen
  [ ] registry.nix an mkEnableOption koppeln
  [ ] inputs.follows in flake.nix für alle Inputs prüfen

MITTELFRISTIG (Qualitäts-Upgrade):
  [ ] NMS-Metadaten aus Kommentar → echtes Nix-Attribut migrieren
  [ ] systemd-analyze security für jeden Service, Ziel < 4.0

OPTIONAL (Nice-to-have):
  [ ] meta.doc in jedem Modul (nixpkgs-Standard)
  [ ] nixos-module-tests für kritische Services (90-policy prüft Struktur,
      aber keine funktionalen Tests)
```
