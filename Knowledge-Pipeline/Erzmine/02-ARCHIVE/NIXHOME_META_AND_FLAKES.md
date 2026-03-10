# 🛰️ NIXHOME V4.0 — VOLLSTÄNDIGE ARCHITEKTUR
## Semantische Layer + NMS-Meta-Standard + Pure Flakes

Stand: 2026-03-02

---

# TEIL 1: DER NMS-META-STANDARD

## Das Problem: Zwei Welten

Deine `.nix`-Dateien haben bereits einen `/**` Block oben.
Aber der ist inkonsistent und vermischt Dinge die getrennt gehören.

**Ziel:** Jede `.nix`-Datei trägt einen einzigen, maschinenlesbaren Header
der gleichzeitig:
- NixOS-Modul-Dokumentation ist (wie nixpkgs `meta {}`)
- Obsidian-YAML-Frontmatter-Vorlage ist
- Von Claude/AI automatisch auslesbar ist
- Die Abhängigkeitsstruktur des Systems beschreibt

---

## Der NMS-Meta-Header (Standard)

```nix
/**
 * ---
 * # ═══════════════════════════════════════════════════════
 * # NMS IDENTITY — Eindeutige Modul-Identität
 * # ═══════════════════════════════════════════════════════
 * nms_version: "2.3"
 * id: "NIXH-40-MEDIA-001"           # Layer-Präfix + Kategorie + Nummer
 * title: "Jellyfin Media Server"
 * description: "Hardware-accelerated media server with declarative QSV encoding"
 * homepage: "https://jellyfin.org/"
 * layer: 40                          # In welchem Layer lebt das Modul?
 *
 * # ═══════════════════════════════════════════════════════
 * # NIXPKGS KLASSIFIKATION — Wo würde das in nixpkgs leben?
 * # ═══════════════════════════════════════════════════════
 * nixpkgs:
 *   path: "pkgs/servers/jellyfin"
 *   category: "servers/media"        # servers|applications|tools|development
 *   source: "https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/jellyfin.nix"
 *
 * # ═══════════════════════════════════════════════════════
 * # CAPABILITIES — Technische Fähigkeiten (durchsuchbar!)
 * # ═══════════════════════════════════════════════════════
 * capabilities:
 *   hardware:
 *     - "gpu/intel-qsv"             # QSV Hardware-Transcoding
 *     - "gpu/opencl"                # OpenCL für Tonemapping
 *   sandboxing:
 *     - "systemd/strict"            # ProtectSystem=strict
 *     - "systemd/private-devices-off" # GPU-Zugriff braucht das
 *   ingress:
 *     - "caddy/reverse-proxy"       # Hinter Caddy
 *     - "tailscale/trusted"         # Tailscale ohne SSO
 *   storage:
 *     - "mergerfs/tier-c"           # Bibliothek auf HDD-Pool
 *     - "mergerfs/cache-b"          # Cache auf SSD-Pool
 *
 * # ═══════════════════════════════════════════════════════
 * # ARCHITEKTUR — Abhängigkeiten (für Dependency-Graph)
 * # ═══════════════════════════════════════════════════════
 * architecture:
 *   upstream:
 *     - "NIXH-00-CORE-001"          # configs.nix (SSoT)
 *     - "NIXH-00-CORE-002"          # ports.nix
 *     - "NIXH-20-SERVER-001"        # caddy.nix
 *   downstream:
 *     - "NIXH-40-MEDIA-002"         # jellyseerr.nix (nutzt Jellyfin API)
 *   status: "audited"               # draft|audited|deprecated
 *
 * # ═══════════════════════════════════════════════════════
 * # RESSOURCEN — Was braucht das Modul?
 * # ═══════════════════════════════════════════════════════
 * resources:
 *   port: 20096                     # aus ports.nix
 *   ram_limit: "4G"                 # MemoryMax in systemd
 *   cpu_weight: 80                  # CPUWeight in systemd
 *   oom_score: 200                  # Je höher, desto früher gekillt
 *   state_path: "/data/state/jellyfin"
 *
 * # ═══════════════════════════════════════════════════════
 * # AUDIT — Qualitätssicherung
 * # ═══════════════════════════════════════════════════════
 * audit:
 *   last_reviewed: "2026-03-02"
 *   complexity: 3                   # 1=trivial, 5=komplex
 *   open_issues: []                 # bekannte TODOs
 * ---
 */
```

---

## Warum dieser Header?

**In Obsidian:** Jede `.nix`-Datei kann direkt als Obsidian-Note importiert werden.
Der YAML-Block oben ist sofort Frontmatter. Dataview-Queries funktionieren sofort:

```dataview
TABLE description, resources.port, audit.last_reviewed
FROM "40-media"
WHERE capabilities.ingress contains "caddy/reverse-proxy"
SORT resources.port ASC
```

**In Claude Code:** Wenn du sagst "analysiere meinen Media Stack",
kann Claude alle `category: "servers/media"` Header einlesen und
sofort eine vollständige Übersicht geben — ohne den Code zu parsen.

**Für Automatisierung:** Das `doc_tagger.sh` Skript kann die Header direkt
extrahieren statt Word-Frequenz zu zählen — viel präziser.

---

## Kurzform-Header für einfache Module

Nicht jede Datei braucht alle Felder. Für triviale Module (complexity: 1):

```nix
/**
 * ---
 * nms_version: "2.3"
 * id: "NIXH-00-CORE-011"
 * title: "Host"
 * description: "Sets hostname from SSoT configs.nix"
 * layer: 0
 * nixpkgs.category: "system/networking"
 * architecture.upstream: ["NIXH-00-CORE-001"]
 * audit.complexity: 1
 * audit.last_reviewed: "2026-03-02"
 * ---
 */
```

---

# TEIL 2: PURE FLAKES — DIE STRUKTURELLE KLAMMER

## Was Flakes für diese Architektur bedeuten

Ein Flake ist im Kern eine `flake.nix` mit drei Blöcken:

```nix
{
  description = "NixHome SRE System";

  inputs = {
    # Alle externen Abhängigkeiten — gepinnt, reproduzierbar
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    sops-nix.url = "github:Mic92/sops-nix";
    # ...
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }: {
    nixosConfigurations.q958 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Hier kommen alle Layer in Reihenfolge
      ];
    };
  };
}
```

**Der entscheidende Vorteil:** `flake.lock` pinnt JEDE Abhängigkeit auf einen
exakten Git-Commit. Dein System ist zu 100% reproduzierbar. Kein "works on my machine".

---

## Wie die Layer-Struktur in Flakes abgebildet wird

### Option A: Ein Import-Hub pro Layer (empfohlen)

Jeder Layer hat eine `_imports.nix` die alle Dateien des Layers sammelt:

```
00-core/_imports.nix
20-server/_imports.nix
30-services/_imports.nix
...
```

Die `flake.nix` importiert nur die 7 Hubs:

```nix
# flake.nix
outputs = { self, nixpkgs, ... }: {
  nixosConfigurations.q958 = nixpkgs.lib.nixosSystem {
    modules = [
      ./00-core/_imports.nix
      ./20-server/_imports.nix
      ./30-services/_imports.nix
      ./40-media/_imports.nix
      ./50-knowledge/_imports.nix
      ./80-monitoring/_imports.nix
      ./90-policy/_imports.nix
    ];
  };
};
```

```nix
# 40-media/_imports.nix  ← Kein meta-Header nötig, das ist ein technischer Hub
{ ... }:
{
  imports = [
    ./media-stack.nix
    ./media-stack-enable.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./sonarr.nix
    ./radarr.nix
    ./lidarr.nix
    ./readarr.nix
    ./prowlarr.nix
    ./sabnzbd.nix
    ./audiobookshelf.nix
    ./recyclarr.nix
    ./arr-wire.nix
    # Interne Helpers (_lib.nix, _servarr-factory.nix) werden
    # von den Modulen selbst importiert — nicht hier
  ];
}
```

**Vorteil:** Wenn du ein Modul deaktivieren willst, kommentierts du es
in `_imports.nix` aus — nicht in der `flake.nix`.

---

### Option B: flake.nix mit direkten Modul-Referenzen (transparenter)

```nix
# flake.nix — vollständig ausgeschrieben
outputs = { self, nixpkgs, home-manager, sops-nix, ... }: {

  nixosConfigurations.q958 = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit self; };

    modules = [

      # ── 00-CORE: OS-Fundament ─────────────────────────────────────────
      ./00-core/configs.nix          # ZUERST: SSoT Master
      ./00-core/defaults.nix         # ZUERST: SSoT Defaults
      ./00-core/ports.nix            # ZUERST: Port-Registry
      ./00-core/registry.nix         # Feature-Flags
      ./00-core/lib-helpers.nix
      ./00-core/hardware-configuration.nix
      ./00-core/host-q958-hardware-configuration.nix
      ./00-core/host-q958-hardware-profile.nix
      ./00-core/host.nix
      ./00-core/users.nix
      ./00-core/secrets.nix
      ./00-core/kernel-slim.nix
      ./00-core/system.nix
      ./00-core/system-stability.nix
      ./00-core/boot-safeguard.nix
      ./00-core/zram-swap.nix
      ./00-core/storage.nix
      ./00-core/backup.nix
      ./00-core/firewall.nix
      ./00-core/fail2ban.nix
      ./00-core/ssh.nix
      ./00-core/ssh-rescue.nix
      ./00-core/network.nix
      ./00-core/locale.nix
      ./00-core/logging.nix
      ./00-core/nix-tuning.nix
      ./00-core/symbiosis.nix

      # ── 20-SERVER: Erreichbarkeit ─────────────────────────────────────
      ./20-server/adguardhome.nix    # DNS zuerst — alles andere braucht DNS
      ./20-server/tailscale.nix
      ./20-server/pocket-id.nix
      ./20-server/sso.nix
      ./20-server/caddy.nix          # Caddy nach Auth-Provider
      ./20-server/cloudflared-tunnel.nix
      ./20-server/postgresql.nix
      ./20-server/valkey.nix
      ./20-server/vpn-confinement.nix
      ./20-server/vpn-live-config.nix
      ./20-server/secret-ingest.nix
      ./20-server/dns-map.nix
      ./20-server/dns-automation.nix
      ./20-server/ddns-updater.nix
      ./20-server/clamav.nix
      ./20-server/landing-zone-ui.nix

      # ── 30-SERVICES: Alltag ───────────────────────────────────────────
      ./30-services/vaultwarden.nix
      ./30-services/homepage.nix
      ./30-services/cockpit.nix
      ./30-services/olivetin.nix
      ./30-services/n8n.nix
      ./30-services/home-assistant.nix
      ./30-services/zigbee-stack.nix
      ./30-services/matrix.nix
      ./30-services/filebrowser.nix
      ./30-services/ollama.nix
      ./30-services/open-webui.nix
      ./30-services/ai-tools.nix
      ./30-services/shell.nix
      ./30-services/shell-premium.nix
      ./30-services/motd.nix
      ./30-services/tty-info.nix
      ./30-services/home-manager.nix
      ./30-services/user-moritz-home.nix
      ./30-services/automation.nix
      ./30-services/auto-locale.nix

      # ── 40-MEDIA: Unterhaltung ────────────────────────────────────────
      ./40-media/media-stack.nix
      ./40-media/media-stack-enable.nix
      ./40-media/jellyfin.nix
      ./40-media/jellyseerr.nix
      ./40-media/sonarr.nix
      ./40-media/radarr.nix
      ./40-media/lidarr.nix
      ./40-media/readarr.nix
      ./40-media/prowlarr.nix
      ./40-media/sabnzbd.nix
      ./40-media/audiobookshelf.nix
      ./40-media/recyclarr.nix
      ./40-media/arr-wire.nix

      # ── 50-KNOWLEDGE: Wissen ─────────────────────────────────────────
      ./50-knowledge/paperless.nix
      ./50-knowledge/miniflux.nix
      ./50-knowledge/readeck.nix
      ./50-knowledge/monica.nix
      ./50-knowledge/karakeep.nix
      # ./50-knowledge/stirling-pdf.nix   # TODO

      # ── 80-MONITORING: Beobachtung ────────────────────────────────────
      ./80-monitoring/netdata.nix
      ./80-monitoring/scrutiny.nix
      ./80-monitoring/uptime-kuma.nix

      # ── 90-POLICY: Enforcement ────────────────────────────────────────
      ./90-policy/flat-layout.nix    # LETZTER: prüft alle anderen Layer

      # ── EXTERNE MODULE (via Flake Inputs) ─────────────────────────────
      home-manager.nixosModules.home-manager
      sops-nix.nixosModules.sops
    ];
  };
};
```

**Vorteil von Option B:** Man sieht in `flake.nix` auf einen Blick
das GESAMTE System. Die Reihenfolge der Imports ist sichtbar dokumentiert.

---

## Die vollständige flake.nix

```nix
# /etc/nixos/flake.nix
{
  description = "🛰️ NixHome SRE System — Q958 Homelab";

  inputs = {
    # ── NIXPKGS ──────────────────────────────────────────────────────────
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ── HOME MANAGER ─────────────────────────────────────────────────────
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";  # ← KRITISCH: gleiche nixpkgs-Version
    };

    # ── SECRETS ──────────────────────────────────────────────────────────
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── VPN CONFINEMENT (falls du das Modul nutzt) ───────────────────────
    # vpn-confinement = {
    #   url = "github:Margatroid/vpn-confinement";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # ── NIXARR (falls du den nixarr Ansatz nutzt) ────────────────────────
    # nixarr = {
    #   url = "github:rasmus-kirk/nixarr";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
  let
    system = "x86_64-linux";
    hostname = "q958";
  in
  {
    # ── HAUPT-SYSTEM ─────────────────────────────────────────────────────
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;

      # specialArgs macht Flake-Inputs in ALLEN Modulen verfügbar
      # ohne dass jedes Modul sie explizit importieren muss
      specialArgs = { inherit inputs self; };

      modules = [
        # Layer-Imports hier (siehe Option B oben)
        # ...
      ];
    };

    # ── DEVELOPMENT SHELL (optional aber nützlich) ────────────────────────
    # Gibt dir eine Shell mit allen nix-Tools die du brauchst:
    # $ nix develop
    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      packages = with nixpkgs.legacyPackages.${system}; [
        sops age git nix-tree nixfmt alejandra
      ];
      shellHook = ''
        echo "🛰️ NixHome Dev Shell"
        echo "   nix flake check  — Syntax prüfen"
        echo "   nix flake update — Alle Inputs aktualisieren"
        echo "   nixos-rebuild switch --flake .#q958 — Deployen"
      '';
    };

    # ── CHECKS (optional: CI-fähige Tests) ────────────────────────────────
    # checks.${system} = {
    #   nixhome = self.nixosConfigurations.q958.config.system.build.toplevel;
    # };
  };
}
```

---

## inputs.follows — Das Wichtigste an Flakes

```nix
home-manager = {
  url = "github:nix-community/home-manager";
  inputs.nixpkgs.follows = "nixpkgs";  # ← Das hier
};
```

**Was das bedeutet:**
Ohne `follows`: home-manager bringt seine eigene nixpkgs-Version mit.
Du hast dann zwei verschiedene nixpkgs im System → manche Pakete werden
doppelt gebaut, Versionen können kollidieren.

Mit `follows`: home-manager nutzt exakt dasselbe nixpkgs wie dein System.
Ein nixpkgs, eine Wahrheit. Genau wie SSoT in deinen `.nix`-Dateien.

---

## Flakes + Layer + Meta: Das Gesamtbild

```
flake.nix
│  inputs: nixpkgs, home-manager, sops-nix  ← gepinnt in flake.lock
│  outputs: nixosConfigurations.q958
│
├── 00-core/           ← OS-Fundament
│   ├── configs.nix    ← NMS-Meta: id: NIXH-00-CORE-001, category: system/config
│   └── ...
│
├── 20-server/         ← Erreichbarkeit
│   ├── caddy.nix      ← NMS-Meta: id: NIXH-20-SERVER-001, category: servers/proxy
│   └── ...
│
├── 40-media/          ← Medienkonsum
│   ├── jellyfin.nix   ← NMS-Meta: id: NIXH-40-MEDIA-001, category: servers/media
│   │                              capabilities: [gpu/intel-qsv, sandboxing/strict]
│   └── ...
│
└── 90-policy/
    └── flat-layout.nix  ← Prüft beim Build: keine Unterordner in den Layers
```

**Der Kreislauf:**
1. `flake.lock` garantiert Reproduzierbarkeit (externe Abhängigkeiten)
2. `90-policy/flat-layout.nix` garantiert Struktur (interne Ordnung)
3. NMS-Meta-Header garantieren Dokumentation (Semantik)
4. Obsidian liest die Header → durchsuchbare Wissensbasis

---

## Nix-Flake Befehle die du täglich brauchst

```bash
# System deployen
sudo nixos-rebuild switch --flake /etc/nixos#q958

# Nur testen (kein persistentes Aktivieren)
sudo nixos-rebuild test --flake /etc/nixos#q958

# Alle Inputs updaten (neue nixpkgs-Version)
nix flake update /etc/nixos

# Nur einen Input updaten (z.B. nur home-manager)
nix flake update /etc/nixos --update-input home-manager

# Syntax-Check ohne Build
nix flake check /etc/nixos

# Was würde sich ändern?
nix store diff-closures /run/current-system $(
  nixos-rebuild build --flake /etc/nixos#q958 2>/dev/null && echo /nix/store/...
)
```

---

## Zusammenfassung: Die drei Ebenen

| Ebene | Tool | Was es löst |
|---|---|---|
| **Reproduzierbarkeit** | `flake.lock` | Externe Abhängigkeiten sind für immer eingefroren |
| **Struktur** | Layer-Architektur + `90-policy/flat-layout.nix` | Interne Ordnung wird beim Build erzwungen |
| **Semantik** | NMS-Meta-Header | Jede Datei weiß was sie ist und wofür sie zuständig ist |

Alle drei Ebenen zusammen ergeben ein System das:
- **reproduzierbar** ist (gleiche Inputs → gleicher Output, immer)
- **verständlich** ist (ein Blick auf den Header erklärt das Modul)
- **durchsuchbar** ist (Obsidian/AI kann die Metadaten auswerten)
- **selbst-schützend** ist (Policy-Layer bricht den Build bei Verstößen)
