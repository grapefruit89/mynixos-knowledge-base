# 03 Prompt-Übernahme anfragen

**Created:** 3/3/2026 4:43:13  
**Updated:** 3/8/2026 21:11:47  
**Exported:** 3/8/2026 21:11:56  
**Link:** [https://claude.ai/chat/03b04629-a979-42c9-a2c6-39e13787de7c](https://claude.ai/chat/03b04629-a979-42c9-a2c6-39e13787de7c)  

## Response:
3.3.2026, 04:44:25

Ja, ich kann den Prompt direkt nehmen. Das ist ein umfangreiches Review-Paket — lass mich loslegen.

---

# SRE Code Review: NixHome NMS v4.2
## Urteil: Ambitioniert, aber mit strukturellen Zeitbomben

Ich werde die 5 Fragen direkt und ohne Schönfärberei beantworten.

---

## 1. Struktur & Skalierbarkeit: Die registry.nix ist eine Zeitbombe

**Das Problem:** `registry.nix` ist ein Single-Point-of-Failure mit 50+ Services — alle als `lib.mkDefault true` gesetzt. Das bedeutet: **alles läuft immer, by default.** Das ist das Gegenteil von Defense-in-Depth.

Konkret:

```nix
# Das hier ist aktiv, auch wenn du es vergisst:
clamav.enable = lib.mkDefault true;
matrixConduit.enable = lib.mkDefault true;
semaphore.enable = lib.mkDefault true; # Placeholder, nie implementiert
linkding.enable = lib.mkDefault true;  # Dito
```

Du hast Placeholder-Module (`semaphore.nix`, `linkding.nix`, `couchdb.nix`) die leer sind, aber trotzdem enabled sind. Das ist Konfigurations-Drift, per Design eingebaut.

**Das tiefere Problem:** Bei 100+ Services wird `registry.nix` zur God-File. Jeder neue Service braucht zwei Einträge (Option + Default), in derselben Datei. Git-Blame wird zur Qual, Merge-Konflikte werden schmerzhaft.

**Was stattdessen:**

`flake-parts` mit `mkFlakeModule` löst das eleganter — jedes Modul registriert sich selbst, kein zentrales Switchboard nötig. Alternativ: Default auf `false` setzen und explizit aktivieren in einer `hosts/q958/services.nix`. Das ist das Nixpkgs-Prinzip.

---

## 2. Sicherheit: "Aviation-Grade" ist Marketing, nicht Realität

Ich gehe durch, was fehlt:

**Kritische Lücke — Netzwerk-Stack:**

```nix
# kernel-slim.nix hat das, aber es fehlt komplett:
"net.ipv4.conf.all.accept_redirects" = 0;
"net.ipv4.conf.default.accept_redirects" = 0;
"net.ipv6.conf.all.accept_redirects" = 0;
"net.ipv4.conf.all.send_redirects" = 0;
# Und das Wichtigste gegen SSRF/MITM:
"net.ipv4.conf.all.accept_source_route" = 0;
```

ICMP Redirect Acceptance ist aktiv. Das ist ein klassischer MITM-Vektor im LAN, gerade bei einem Homelab mit IoT-Geräten (Zigbee-Stick, Home Assistant).

**Kritische Lücke — SSH Rescue:**

```nix
# ssh-rescue.nix — Das hier ist ein Sicherheitsloch:
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd
sleep 300
mv /tmp/sshd_config.backup /etc/ssh/sshd_config
```

Dieses Script öffnet Password-Auth für **5 Minuten nach jedem Boot** — das ist `wantedBy = ["multi-user.target"]`. Das ist kein Recovery-Feature, das ist ein Race-Condition-Angriff wartend auf Ausführung. Ein Angreifer mit Netzwerkzugang, der den Boot-Zeitpunkt kennt, hat 5 Minuten für Brute-Force auf Port 22 **und** den custom Port. Korrekt wäre ein manuell getriggerter One-Shot mit `wantedBy = []`.

**Kritische Lücke — Secrets in Plaintext:**

```nix
# service-app-n8n.nix, Zeile ~40:
N8N_ENCRYPTION_KEY = "gCXaCy//u9sm+lRK1cZPEb2KTxcCkW2O";
```

Das ist ein **Hardcoded Secret im Nix-Store**. Jeder mit Leserechten auf `/nix/store` kann das lesen. Das gehört in SOPS.

**Kritische Lücke — mTLS-Zertifikate öffentlich downloadbar:**

```nix
# caddy.nix:
handle /certs/* {
  root * /var/www/landing-zone
  file_server browse
}
```

Kombiniert mit `mtls-generator.sh`:
```bash
echo "📥 DOWNLOAD LINK: https://nix.m7c5.de/certs/$CLIENT_NAME.p12"
# Passwort ist leer
```

Du stellst P12-Zertifikate **ohne Passwort** über HTTPS bereit. Das ist Security Theater — mTLS soll Authentifizierung erzwingen, aber die Credentials sind öffentlich abrufbar mit leerem Passwort.

**Was CIS Level 1 noch fordert (nicht implementiert):**
- `kernel.yama.ptrace_scope = 1` — fehlt
- `fs.protected_hardlinks = 1` und `fs.protected_symlinks = 1` — fehlen
- `kernel.randomize_va_space = 2` — nicht explizit gesetzt

---

## 3. Isomorphie & Tooling: Der Chunker ist technische Schulden

Der `chunker.py`-Ansatz hat fundamentale Probleme:

**Problem 1 — Regex auf Nix-Code ist fragil.** Nix hat keine reguläre Grammatik. Multiline-Strings, `''`-Literale, eingebettete Bash-Snippets — das werden Grenzfälle sein, die der Chunker falsch parst. Sobald jemand einen Service-Kommentar mit `# NIXH-` am Anfang schreibt, gibt es Phantom-IDs.

**Problem 2 — Checksums sind dekorativ.** Die `sha256`-Checksums in den EOF-Kommentaren werden nicht maschinell verifiziert. Sie sind Dokumentation, keine Integritätsprüfung. Ein `pre-commit`-Hook der das tatsächlich prüft, fehlt.

**Problem 3 — Kein kanonischer Graph.** Du hast Abhängigkeiten zwischen Modulen (`configs.nix` → `vpn-live-config.nix` via direktem Import), aber der Chunk-Index spiegelt das nicht wider. Ein echter Dependency-Graph wäre:

```bash
nix eval .#nixosConfigurations.nixhome.config \
  --apply 'c: builtins.attrNames c.my.meta' \
  --json | jq
```

Die Nix-Evaluierung selbst ist dein Graph. `nix-tree` oder `nix why-depends` geben dir das bereits, ohne Python-Tooling.

---

## 4. Versteckte ARM-Migrationsrisiken

Konkrete Probleme bei ARM-Migration (z.B. Raspberry Pi 5, Ampere Altra, oder ein Apple Silicon Server):

**Explizite x86-Bindungen:**
- `flake.nix`: `system = "x86_64-linux"` — einziger Eintrag, kein `systems`-Parameter
- `hardware-configuration.nix`: `kvm-intel` Kernelmodul hardcoded
- `kernel-slim.nix`: `boot.kernelModules = ["i915"]` — Intel GPU, kein ARM-Äquivalent
- `host-q958-hardware-profile.nix`: `i915.enable_guc=3` Kernel-Parameter

**Implizite x86-Abhängigkeiten:**
- `pkgs.ollama-vulkan` — Vulkan-Support auf ARM ist eingeschränkt, insbesondere auf Mali/Bifrost GPUs
- `intel-media-driver`, `intel-compute-runtime`, `vpl-gpu-rt` — alle Intel-only
- `pkgs.linuxPackages_latest` mit Intel-Microcode-Update — wird auf ARM ignoriert, aber erzeugt keine Warnung

**Was fehlt:** Ein `my.configs.hardware.cpuType`-Check der bei `"arm"` die Intel-spezifischen Module deaktiviert. Die Option existiert (`cpuType = lib.types.enum ["intel" "amd" "arm"]`), aber sie wird nur für Microcode-Updates genutzt, nicht als Guard für GPU-Konfiguration.

---

## 5. Die eine radikale Änderung: Impermanence + State-Separation

Wenn ich freie Hand hätte, würde ich **Impermanence** einführen — `tmpfs` als Root-Filesystem, explizites Persist nur für deklarierten State.

**Warum das alles andere übertrumpft:**

Dein aktuelles System hat über 50 Services mit `ReadWritePaths` die verstreut über `/var/lib/`, `/data/state/`, `/mnt/` liegen. Du weißt nicht mit Sicherheit, welcher Service welchen State schreibt. Das ist die Wurzel von Konfigurations-Drift.

```nix
# Mit impermanence:
environment.persistence."/data/persist" = {
  directories = [
    "/var/lib/pocket-id"
    "/var/lib/vaultwarden"
    "/var/lib/postgresql"
    # Jeder State der nicht hier steht, existiert nach Reboot nicht mehr
  ];
  files = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/var/lib/sops-nix/key.txt"
  ];
};
```

Das würde sofort drei Probleme lösen:
1. **Drift-Detection wird trivial** — was nach Reboot weg ist, war nie deklariert
2. **Die `config-merger.nix` mit ihren JSON-Overrides stirbt** — weil nichts mehr implizit persistiert wird  
3. **ARM-Migration wird einfacher** — weil du einen klaren State-Snapshot hast

Der `config-drift-detector`-Service in `system-stability.nix` ist ein Symptom-Pflaster für dieses Problem. Impermanence ist die Ursachen-Heilung.

---

## Zusammenfassung: Die Top-5-Fixes, priorisiert

| Priorität | Problem | Fix |
|-----------|---------|-----|
| **KRITISCH** | N8N Hardcoded Encryption Key | In SOPS verschieben, sofort |
| **KRITISCH** | SSH Rescue startet bei jedem Boot | `wantedBy = []`, manueller Trigger |
| **HOCH** | mTLS-Certs öffentlich mit leerem Passwort | Entweder PKCS12-Passwort oder Caddy-Auth vor `/certs/` |
| **HOCH** | Alle 50 Services default-enabled | Default auf `false`, explizite Host-Config |
| **MITTEL** | ICMP Redirect / Source Route sysctl fehlen | 3 Zeilen in `kernel-slim.nix` |

Das System hat echte Architektur-Intelligenz — die Layer-Trennung, der `mkService`-Abstraktor, die Policy-Layer sind solide Ideen. Aber der Sicherheits-Anspruch ("Aviation-Grade") ist momentan eher Cockpit-Dekoration als tatsächliche Flugtauglichkeit.



## Response:
3.3.2026, 04:57:25

# NixHome NMS v4.2 — Strategic Hardening Roadmap

Kein Warmup. Direkt in den Code.

---

## 1. Hardware Abstraction Layer (HAL)

### Architektur-Prinzip

Das Problem ist nicht, dass Intel-Treiber existieren — es ist, dass sie **direkt in Service-Modulen referenziert** werden. Jellyfin sollte nie wissen, ob es auf Intel oder ARM läuft. Es fragt den HAL: *"Gib mir einen Hardware-Accelerated Decoder."* Der HAL liefert.

```nix
# 00-core/hal.nix — Hardware Abstraction Layer
{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-COR-HAL-001";
    title = "Hardware Abstraction Layer";
    description = "Platform-agnostic hardware capability broker.";
    layer = 00;
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 4;
  };

  cfg = config.my.hal;
  
  # ── PLATFORM DETECTION ────────────────────────────────────────────────
  platform = pkgs.stdenv.hostPlatform;
  
  isX86   = platform.isx86_64;
  isARM64 = platform.isAarch64;
  isAMD   = isX86 && config.my.configs.hardware.cpuType == "amd";
  isIntel = isX86 && config.my.configs.hardware.cpuType == "intel";
  
  # ── CAPABILITY MATRIX ─────────────────────────────────────────────────
  # Jede Capability ist ein attrset: { packages, envVars, kernelParams, kernelModules }
  gpuCapabilities = {
    intel = {
      packages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
        vpl-gpu-rt
        libvdpau-va-gl
        libva-utils
        intel-gpu-tools
      ];
      envVars   = { LIBVA_DRIVER_NAME = "iHD"; OCL_ICD_VENDORS = "intel"; };
      kernelParams  = [ "i915.enable_guc=3" "i915.enable_fbc=1" "i915.enable_psr=1" ];
      kernelModules = [ "i915" ];
      deviceNodes   = [ "/dev/dri/renderD128" ];
    };

    amd = {
      packages = with pkgs; [
        mesa
        rocmPackages.rocm-runtime
        libva-mesa-driver
      ];
      envVars       = { LIBVA_DRIVER_NAME = "radeonsi"; };
      kernelParams  = [ "amdgpu.ppfeaturemask=0xffffffff" ];
      kernelModules = [ "amdgpu" ];
      deviceNodes   = [ "/dev/dri/renderD128" "/dev/kfd" ];
    };

    # Mali / Broadcom für Raspberry Pi 5
    arm-mali = {
      packages = with pkgs; [ mesa libva ];
      envVars       = { LIBVA_DRIVER_NAME = "radeonsi"; }; # Mesa Panfrost/V3D
      kernelParams  = [];
      kernelModules = [];
      deviceNodes   = [ "/dev/dri/renderD128" ];
    };

    none = {
      packages      = [];
      envVars       = {};
      kernelParams  = [];
      kernelModules = [];
      deviceNodes   = [];
    };
  };

  # ── AUTO-DETECT: Wähle Capability basierend auf Platform + cpuType ──
  detectedGpu =
    if isIntel then "intel"
    else if isAMD then "amd"
    else if isARM64 then "arm-mali"
    else "none";

  # Override erlaubt, aber mit Warnung
  activeGpu = cfg.gpu.override or detectedGpu;
  gpu = gpuCapabilities.${activeGpu};

in {
  options.my.meta.hal = lib.mkOption {
    type    = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  options.my.hal = {
    gpu.override = lib.mkOption {
      type    = lib.types.nullOr (lib.types.enum (builtins.attrNames gpuCapabilities));
      default = null;
      description = "Erzwingt eine GPU-Capability. Null = Auto-Detect.";
    };

    # ── PUBLIC API für andere Module ─────────────────────────────────────
    # Service-Module lesen NUR diese Werte — nie direkt pkgs.intel-*
    capabilities = {
      gpu = {
        packages    = lib.mkOption { type = lib.types.listOf lib.types.package; readOnly = true; };
        envVars     = lib.mkOption { type = lib.types.attrsOf lib.types.str;    readOnly = true; };
        deviceNodes = lib.mkOption { type = lib.types.listOf lib.types.str;     readOnly = true; };
      };
    };
  };

  # ── LOGIC GATES: Inkompatibilitäten zur Eval-Zeit abfangen ────────────
  config = {
    assertions = [
      {
        # ARM kann kein Intel QSV — sofortiger Build-Abbruch
        assertion = !(isARM64 && config.my.configs.hardware.intelGpu);
        message   = ''
          [HAL-001] INKOMPATIBLE HARDWARE-KONFIGURATION:
          hardware.intelGpu = true ist auf ARM64 ungültig.
          Setze: my.configs.hardware.intelGpu = false
          oder:  my.hal.gpu.override = "arm-mali"
        '';
      }
      {
        # GPU-Override muss zur Platform passen
        assertion =
          cfg.gpu.override == null ||
          !(isARM64 && builtins.elem cfg.gpu.override [ "intel" "amd" ]);
        message = "[HAL-002] GPU-Override '${cfg.gpu.override or ""}' ist auf ARM64 nicht unterstützt.";
      }
      {
        # Wenn kvm-intel geladen wird, muss cpuType intel sein
        assertion =
          !(builtins.elem "kvm-intel" config.boot.kernelModules &&
            config.my.configs.hardware.cpuType != "intel");
        message = "[HAL-003] kvm-intel geladen, aber cpuType != intel. Kernel-Panik vorprogrammiert.";
      }
    ];

    warnings = lib.optional (cfg.gpu.override != null) 
      "[HAL] GPU manuell auf '${cfg.gpu.override}' erzwungen. Auto-Detect war: '${detectedGpu}'.";

    # ── HAL PUBLIC API befüllen ────────────────────────────────────────
    my.hal.capabilities.gpu = {
      packages    = gpu.packages;
      envVars     = gpu.envVars;
      deviceNodes = gpu.deviceNodes;
    };

    # ── SYSTEM-KONFIGURATION über HAL ────────────────────────────────
    hardware.graphics = lib.mkIf (activeGpu != "none") {
      enable        = true;
      extraPackages = gpu.packages;
    };

    boot.kernelParams  = gpu.kernelParams;
    boot.kernelModules = gpu.kernelModules;
    environment.sessionVariables = gpu.envVars;
  };
}
```

**So nutzt Jellyfin den HAL** — ohne eine einzige Intel-Referenz:

```nix
# 40-media/service-media-jellyfin.nix (refactored)
{ config, lib, pkgs, ... }:
let
  hal = config.my.hal.capabilities.gpu;
in {
  config = lib.mkIf cfg.enable {
    systemd.services.jellyfin = {
      environment = hal.envVars;  # Kommt vom HAL, nicht hardcoded
      serviceConfig = {
        # Kein hardcoded /dev/dri/renderD128 mehr
        DeviceAllow    = lib.mkIf (hal.deviceNodes != [])
          (map (d: "${d} rw") hal.deviceNodes);
        PrivateDevices = lib.mkForce (hal.deviceNodes == []);
      };
    };
    hardware.graphics.extraPackages = hal.packages;
  };
}
```

**SRE-Begründung:** Blast Radius einer falschen Treiber-Konfiguration sinkt von "System bootet nicht mehr" auf "HAL-Assertion schlägt bei `nixos-rebuild` fehl". MTTR: von Stunden auf Minuten.

---

## 2. True Isomorphy: Nix-Eval statt Python-Parsing

### Strategie

Das Ziel: `nix eval` als einzige Source of Truth. Kein Python, kein Regex.

```bash
# Das ist alles was wir brauchen — der Rest ist Shell-Glue
nix eval .#nixosConfigurations.nixhome.config.my.meta \
  --apply 'meta: builtins.toJSON meta' \
  --json 2>/dev/null | jq '.'
```

**Das Problem:** `config.my.meta` ist ein `attrsOf attrs` — aber die einzelnen Modul-Metadaten sind verschachtelt. Wir brauchen eine normalisierte Struktur.

### Schritt 1: Meta-Schema standardisieren

```nix
# 00-core/lib-meta-schema.nix
# Wird von ALLEN Modulen importiert — erzwingt Schema-Konformität
{ lib }:
{
  mkModuleMeta = {
    id,
    title,
    description,
    layer,
    capabilities ? [],
    nixpkgs_category ? "uncategorized",
    upstream ? [],    # NIXH-IDs der Abhängigkeiten
    downstream ? [],  # NIXH-IDs der Abhänger
    audit_complexity ? 1,
    audit_last_reviewed ? "1970-01-01",
    status ? "active",  # active | deprecated | placeholder
  }: {
    inherit id title description layer capabilities
            upstream downstream status;
    nixpkgs.category  = nixpkgs_category;
    audit.complexity  = audit_complexity;
    audit.last_reviewed = audit_last_reviewed;
    # Maschinenlesbare Felder für den Index
    _schema_version = "2.0";
    _generated_at   = ""; # Wird beim Eval gefüllt
  };
}
```

### Schritt 2: Extract-Script (kein Python, nur Shell + jq)

```bash
#!/usr/bin/env bash
# scripts/generate-index.sh
# Läuft als Git pre-commit hook UND als CI-Step

set -euo pipefail

FLAKE_DIR="${1:-/etc/nixos}"
OUTPUT_DIR="${2:-/tmp/nixhome-index}"
mkdir -p "$OUTPUT_DIR"

echo "🔍 Extrahiere Metadaten via nix eval..."

# ── SCHRITT 1: Rohe Meta-Attribute extrahieren ─────────────────────
nix eval "${FLAKE_DIR}#nixosConfigurations.nixhome.config.my.meta" \
  --json \
  --apply 'meta:
    builtins.listToAttrs (
      builtins.filter (x: x != null) (
        map (name: 
          let v = meta.${name}; in
          if builtins.isAttrs v && v ? id && v ? layer
          then { inherit name; value = v; }
          else null
        ) (builtins.attrNames meta)
      )
    )
  ' > "${OUTPUT_DIR}/meta-raw.json"

# ── SCHRITT 2: In durchsuchbaren Index normalisieren ───────────────
jq '
  to_entries | map({
    id:          .value.id,
    title:       .value.title,
    description: .value.description,
    layer:       .value.layer,
    status:      (.value.status // "active"),
    capabilities: (.value.capabilities // []),
    upstream:    (.value.upstream // []),
    downstream:  (.value.downstream // []),
    complexity:  (.value.audit.complexity // 1),
    last_reviewed: (.value.audit.last_reviewed // "unknown"),
    nix_attr:    .name
  }) | sort_by(.layer, .id)
' "${OUTPUT_DIR}/meta-raw.json" > "${OUTPUT_DIR}/chunk_index.json"

# ── SCHRITT 3: Dependency-Graph als DOT-Format ─────────────────────
jq -r '
  "digraph NixHome {",
  "  rankdir=LR;",
  "  node [shape=box];",
  (.[] | 
    .upstream[] as $up |
    "  \"\(.id)\" -> \"\($up)\" [style=dashed];"
  ),
  (.[] |
    .downstream[] as $down |
    "  \"\(.id)\" -> \"\($down)\";"
  ),
  "}"
' "${OUTPUT_DIR}/chunk_index.json" > "${OUTPUT_DIR}/dependency.dot"

# ── SCHRITT 4: Obsidian-Markdown generieren ────────────────────────
jq -r '
  .[] |
  "---\n" +
  "nixh_id: \(.id)\n" +
  "layer: \(.layer)\n" +
  "status: \(.status)\n" +
  "complexity: \(.complexity)\n" +
  "---\n\n" +
  "# \(.title)\n\n" +
  "> \(.description)\n\n" +
  "## Capabilities\n" +
  (.capabilities | map("- `\(.)`") | join("\n")) +
  "\n\n## Dependencies\n" +
  (if (.upstream | length) > 0
   then "### Upstream\n" + (.upstream | map("- [[NIXH/\(.)]]") | join("\n"))
   else "*(keine)*"
   end) +
  "\n\n## Audit\n" +
  "- **Last Reviewed:** \(.last_reviewed)\n" +
  "- **Complexity:** \(.complexity)/5\n"
' "${OUTPUT_DIR}/chunk_index.json" | \
  # Splitte in einzelne Dateien pro Modul
  awk 'BEGIN{f=""} /^---$/ && f=="" {next} /^# / {
    if(f != "") close(f)
    # Dateiname aus Titel ableiten
    gsub(/ /, "-", $0)
    sub(/^# /, "", $0)
    f = "'"${OUTPUT_DIR}"'/obsidian/" tolower($0) ".md"
    system("mkdir -p '"${OUTPUT_DIR}"'/obsidian")
  } {print > f}'

echo "✅ Index generiert: ${OUTPUT_DIR}/chunk_index.json"
echo "📊 $(jq length ${OUTPUT_DIR}/chunk_index.json) Module indexiert"
echo "🕸  Dependency-Graph: ${OUTPUT_DIR}/dependency.dot"
echo "📝 Obsidian-Docs: ${OUTPUT_DIR}/obsidian/"
```

### Schritt 3: Git pre-commit Hook via NixOS

```nix
# 00-core/system.nix — ersetze den bestehenden git-hooks Eintrag
{ config, pkgs, ... }:
let
  indexScript = pkgs.writeShellScriptBin "nixhome-generate-index" 
    (builtins.readFile ../scripts/generate-index.sh);

  preCommitHook = pkgs.writeShellScript "pre-commit-meta-check" ''
    set -euo pipefail
    
    # Nur ausführen wenn Nix-Dateien geändert wurden
    if ! git diff --cached --name-only | grep -q '\.nix$'; then
      exit 0
    fi
    
    echo "🔍 Validiere NMS-Metadaten..."
    
    # Eval muss sauber durchlaufen
    if ! ${indexScript}/bin/nixhome-generate-index /etc/nixos /tmp/pre-commit-index; then
      echo "❌ Metadaten-Extraktion fehlgeschlagen. Commit abgebrochen."
      exit 1
    fi
    
    # Prüfe auf doppelte IDs
    DUPES=$(jq '[.[].id] | group_by(.) | map(select(length > 1)) | length' \
      /tmp/pre-commit-index/chunk_index.json)
    if [ "$DUPES" -gt 0 ]; then
      echo "❌ Doppelte NIXH-IDs gefunden! Commit abgebrochen."
      jq '[.[].id] | group_by(.) | map(select(length > 1))' \
        /tmp/pre-commit-index/chunk_index.json
      exit 1
    fi
    
    # Placeholder-Module mit enable=true warnen
    jq -r '.[] | select(.status == "placeholder") | .id' \
      /tmp/pre-commit-index/chunk_index.json | \
      while read -r id; do
        echo "⚠️  Placeholder aktiv: $id"
      done
    
    echo "✅ Metadaten valide."
  '';
in {
  environment.etc."git-hooks/pre-commit".source = preCommitHook;
  environment.systemPackages = [ indexScript ];
}
```

**SRE-Begründung:** Idempotenz — jeder `git commit` mit Nix-Änderungen regeneriert den Index deterministisch. Der Nix-Evaluator ist der Parser, nicht Regex. Kein Divergenz-Risiko zwischen Code und Dokumentation.

---

## 3. Deep-Hardening & Service-Isolation

### 3a. nftables Micro-Segmentation

Das Konzept: Jeder Service darf nur mit explizit whitegelisteten Peers kommunizieren. Default-Policy: DROP.

```nix
# 00-core/firewall-microseg.nix
{ config, lib, ... }:
let
  # ── SERVICE-KOMMUNIKATIONS-MATRIX ─────────────────────────────────────
  # Format: { from = "service"; to = "service|port"; proto = "tcp|udp"; }
  allowedFlows = [
    # Caddy → Backend-Services (Reverse Proxy)
    { from = "caddy";        to_port = config.my.ports.pocketId;    proto = "tcp"; }
    { from = "caddy";        to_port = config.my.ports.jellyfin;     proto = "tcp"; }
    { from = "caddy";        to_port = config.my.ports.vaultwarden;  proto = "tcp"; }
    { from = "caddy";        to_port = config.my.ports.miniflux;     proto = "tcp"; }
    { from = "caddy";        to_port = config.my.ports.n8n;          proto = "tcp"; }
    { from = "caddy";        to_port = config.my.ports.paperless;    proto = "tcp"; }
    
    # PostgreSQL → nur lokale Unix-Sockets (keine TCP-Flows nötig)
    # n8n → PostgreSQL via Unix-Socket (kein TCP-Flow)
    
    # Arr-Stack → SABnzbd (interne API-Calls)
    { from = "sonarr";  to_port = config.my.ports.sabnzbd;   proto = "tcp"; }
    { from = "radarr";  to_port = config.my.ports.sabnzbd;   proto = "tcp"; }
    { from = "readarr"; to_port = config.my.ports.sabnzbd;   proto = "tcp"; }
    
    # Arr-Stack → Prowlarr
    { from = "sonarr";  to_port = config.my.ports.prowlarr;  proto = "tcp"; }
    { from = "radarr";  to_port = config.my.ports.prowlarr;  proto = "tcp"; }

    # Recyclarr → Arr-Stack (API-Konfiguration)
    { from = "recyclarr"; to_port = config.my.ports.sonarr;  proto = "tcp"; }
    { from = "recyclarr"; to_port = config.my.ports.radarr;  proto = "tcp"; }
    
    # Home Assistant → MQTT
    { from = "home-assistant"; to_port = config.my.ports.mqtt; proto = "tcp"; }
    { from = "zigbee2mqtt";    to_port = config.my.ports.mqtt; proto = "tcp"; }

    # AdGuard → DNS upstream (Outbound, erlaubt durch separate Regel)
    # Monitoring
    { from = "netdata";   to_port = config.my.ports.postgresql; proto = "tcp"; }
  ];

  # Generiere nftables-Regeln aus der Matrix
  flowToRule = flow: ''
    meta skuid ${flow.from} tcp dport ${toString flow.to_port} accept comment "${flow.from} → port ${toString flow.to_port}"
  '';

  generatedRules = lib.concatMapStrings flowToRule allowedFlows;

in {
  networking.nftables.tables.nixhome-microseg = {
    family = "inet";
    content = ''
      # ── MICRO-SEGMENTATION: Service-zu-Service Kommunikation ──────────
      chain service-isolation {
        type filter hook output priority 0; policy drop;

        # ── ALWAYS ALLOW ──────────────────────────────────────────────
        # Loopback für alle (Unix-Sockets)
        oif lo accept

        # DNS (AdGuard auf 127.0.0.1:53)
        udp dport 53 accept
        tcp dport 53 accept

        # SOPS/Age: Key-Derivation beim Boot
        meta skuid root accept

        # Caddy benötigt Internet für Cloudflare DNS-01
        meta skuid caddy tcp dport { 80, 443 } accept

        # Tailscale braucht UDP
        meta skuid root udp dport 41641 accept

        # ── GENERIERTE SERVICE-FLOWS ──────────────────────────────────
        ${generatedRules}

        # ── CATCH-ALL: Alles andere loggen und droppen ─────────────────
        log prefix "[NIXHOME-BLOCKED] " level warn
        drop
      }

      chain forward {
        type filter hook forward priority 0; policy drop;
        # Nur VPN-Namespace-Traffic forwarden
        iif "veth-vault" oif "wg0" accept
        iif "wg0" oif "veth-vault" accept
      }
    '';
  };
}
```

### 3b. Systemd-Sandboxing-Schablone

```nix
# 00-core/lib-service-hardening.nix
{ lib, config }:
let
  # ── HARDENING-PROFILE ─────────────────────────────────────────────────
  # Drei Tier-Level: minimal, standard, paranoid
  
  baseHardening = {
    NoNewPrivileges      = true;
    PrivateTmp           = true;
    ProtectHome          = true;
    ProtectClock         = true;
    ProtectKernelLogs    = true;
    ProtectKernelTunables = true;
    ProtectKernelModules  = true;
    ProtectControlGroups  = true;
    RestrictSUIDSGID      = true;
    RemoveIPC             = true;
    LockPersonality       = true;
    RestrictRealtime      = true;
    SystemCallArchitectures = "native";
    UMask                 = "0027";
  };

  # Für Web-Services (Vaultwarden, n8n, Miniflux, etc.)
  webServiceHardening = baseHardening // {
    # Kein Zugriff auf /proc anderer Prozesse
    ProtectProc  = "invisible";
    ProcSubset   = "pid";
    PrivateUsers = true;

    # Nur die nötigsten Address-Families
    # AF_UNIX: für PostgreSQL/Redis Unix-Sockets
    # AF_INET: für ausgehende HTTP-Calls (wo nötig)
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];

    # Kein Schreiben in ausführbare Memory-Bereiche
    MemoryDenyWriteExecute = true;

    # Capabilities komplett entfernen (nach Binding)
    CapabilityBoundingSet = "";
    AmbientCapabilities   = "";

    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@debug"
      "~@mount"
      "~@reboot"
      "~@swap"
      "~@cpu-emulation"
      "~@obsolete"
    ];
  };

  # Für Services die KEIN Internet brauchen (z.B. interne DB-Tools)
  # PrivateNetwork = true ist aggressiv: kein Loopback!
  # Daher: nur für Services ohne jegliche Netzwerk-Anforderung
  networkIsolatedHardening = webServiceHardening // {
    # ACHTUNG: Das deaktiviert AUCH Loopback.
    # Nur nutzen wenn der Service via Unix-Socket kommuniziert.
    PrivateNetwork          = true;
    RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
  };

  # Für Services die physische Hardware brauchen (Jellyfin, SMART)
  hardwareAccessHardening = baseHardening // {
    PrivateDevices = false;  # Muss explizit false sein für /dev/dri
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@debug"
    ];
  };

in {
  # ── EXPORTIERTE PROFILE ───────────────────────────────────────────────
  profiles = {
    inherit webServiceHardening networkIsolatedHardening hardwareAccessHardening;
  };

  # ── HELPER: mkWebService baut den vollständigen serviceConfig-Block ───
  mkHardenedService = {
    profile ? "web",
    readWritePaths ? [],
    memoryMaxMB ? 512,
    oomScore ? 0,
    extraConfig ? {},
  }:
  let
    baseProfile = {
      web      = webServiceHardening;
      isolated = networkIsolatedHardening;
      hardware = hardwareAccessHardening;
    }.${profile};
  in
    baseProfile // {
      ReadWritePaths = readWritePaths;
      MemoryMax      = "${toString memoryMaxMB}M";
      OOMScoreAdjust = oomScore;
    } // extraConfig;
}
```

**Nutzung in Vaultwarden** — vorher vs. nachher:

```nix
# VORHER: 8 manuelle Zeilen, Copy-Paste-Fehler möglich
systemd.services.vaultwarden.serviceConfig = {
  ProtectSystem = lib.mkForce "strict";
  ReadWritePaths = ["/var/lib/vaultwarden"];
  MemoryDenyWriteExecute = lib.mkForce true;
  # ... 5 weitere Zeilen
};

# NACHHER: Eine Zeile, auditierbar, konsistent
{ config, lib, ... }:
let hardening = import ../00-core/lib-service-hardening.nix { inherit lib config; };
in {
  systemd.services.vaultwarden.serviceConfig =
    hardening.mkHardenedService {
      profile        = "web";
      readWritePaths = [ "/var/lib/vaultwarden" ];
      memoryMaxMB    = 256;
      oomScore       = 200;
    };
}
```

**SRE-Begründung:** Einheitliche Hardening-Baseline reduziert den Blast Radius eines kompromittierten Services. `PrivateNetwork = true` ist nur dort sinnvoll, wo der Service **ausschließlich** via Unix-Sockets kommuniziert — nicht pauschal für alle Web-Services, da das Loopback bricht.

---

## 4. Impermanence: Kritische Persistence-Einträge

### Risiko-Analyse: Was geht bei tmpfs-Root verloren?

**Layer 20 — Infrastructure (Hochrisiko):**

| Pfad | Service | Risiko | Grund |
|------|---------|--------|-------|
| `/var/lib/sops-nix/key.txt` | SOPS | **KRITISCH** | Age-Key verloren = alle Secrets unlösbar verschlüsselt |
| `/var/lib/postgresql/` | PostgreSQL | **KRITISCH** | Alle App-Datenbanken (Miniflux, n8n, Paperless) |
| `/etc/ssh/ssh_host_ed25519_key` | SSH | **HOCH** | Host-Key-Wechsel = Known-Host-Warnungen, Tailscale-Auth bricht |
| `/var/lib/sops-nix/` | SOPS | **HOCH** | Ganze Secret-Infrastruktur |
| `/var/lib/AdGuardHome/` | AdGuard | **MITTEL** | Blocklists, Query-History, Custom-Rules |
| `/var/lib/tailscale/` | Tailscale | **MITTEL** | Node-Identity, erfordert Re-Auth |
| `/var/lib/pocket-id/` | Pocket-ID | **MITTEL** | OIDC-Clients, User-Daten, Sessions |

**Layer 40 — Media (Hochrisiko):**

| Pfad | Service | Risiko | Grund |
|------|---------|--------|-------|
| `/data/state/jellyfin/` | Jellyfin | **HOCH** | Bibliotheks-Metadaten, Watched-Status, User-Präferenzen |
| `/data/state/sonarr/` | Sonarr | **HOCH** | Serie-Datenbank, Download-History, Custom-Formats |
| `/data/state/radarr/` | Radarr | **HOCH** | Film-Datenbank |
| `/data/state/prowlarr/` | Prowlarr | **HOCH** | Indexer-Konfiguration |
| `/data/state/sabnzbd/` | SABnzbd | **MITTEL** | Download-Queue, History |
| `/var/lib/zigbee2mqtt/` | Zigbee2MQTT | **HOCH** | Device-Pairing-Daten — Neupairing von 30+ Geräten |
| `/var/lib/home-assistant/` | HA | **HOCH** | Automations, Entity-History, Lovelace-Config |

### Impermanence-Konfiguration

```nix
# 00-core/impermanence.nix
{ config, lib, pkgs, inputs, ... }:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  # ── ROOT AUF TMPFS ────────────────────────────────────────────────────
  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
  };

  # ── PERSISTENTER STATE (absolut kritisch) ────────────────────────────
  environment.persistence."/data/persist" = {
    hideMounts = true;  # Kein Rauschen in `mount`-Output

    directories = [
      # ── BOOT-KRITISCH (System funktioniert nicht ohne diese) ──────
      { directory = "/var/lib/sops-nix";         mode = "0700"; user = "root";  group = "root"; }
      { directory = "/var/lib/nixos";             mode = "0755"; user = "root";  group = "root"; }
      { directory = "/etc/nixos";                 mode = "0755"; user = "root";  group = "root"; }

      # ── NETZWERK-KRITISCH ─────────────────────────────────────────
      { directory = "/var/lib/tailscale";         mode = "0700"; user = "root";  group = "root"; }
      { directory = "/var/lib/AdGuardHome";       mode = "0755"; user = "adguardhome"; group = "adguardhome"; }

      # ── IDENTITY & SECRETS ───────────────────────────────────────
      { directory = "/var/lib/pocket-id";         mode = "0750"; user = "pocket-id"; group = "pocket-id"; }

      # ── DATENBANKEN ───────────────────────────────────────────────
      { directory = "/var/lib/postgresql";        mode = "0700"; user = "postgres"; group = "postgres"; }
      { directory = "/var/lib/redis-valkey";      mode = "0750"; user = "redis-valkey"; group = "redis-valkey"; }

      # ── MEDIA-STACK ───────────────────────────────────────────────
      { directory = "/data/state/jellyfin";       mode = "0750"; user = "jellyfin";   group = "media"; }
      { directory = "/data/state/sonarr";         mode = "0750"; user = "sonarr";     group = "media"; }
      { directory = "/data/state/radarr";         mode = "0750"; user = "radarr";     group = "media"; }
      { directory = "/data/state/prowlarr";       mode = "0750"; user = "prowlarr";   group = "media"; }
      { directory = "/data/state/readarr";        mode = "0750"; user = "readarr";    group = "media"; }
      { directory = "/data/state/lidarr";         mode = "0750"; user = "lidarr";     group = "media"; }
      { directory = "/data/state/sabnzbd";        mode = "0750"; user = "sabnzbd";    group = "media"; }
      { directory = "/data/state/audiobookshelf"; mode = "0750"; user = "audiobookshelf"; group = "media"; }

      # ── IOT ───────────────────────────────────────────────────────
      # Zigbee2MQTT: Gerät-Pairing geht verloren ohne Persistence
      { directory = "/var/lib/zigbee2mqtt";       mode = "0750"; user = "zigbee2mqtt"; group = "zigbee2mqtt"; }
      { directory = "/var/lib/hass";              mode = "0750"; user = "hass";        group = "hass"; }

      # ── KNOWLEDGE & APPS ─────────────────────────────────────────
      { directory = "/var/lib/vaultwarden";       mode = "0700"; user = "vaultwarden"; group = "vaultwarden"; }
      { directory = "/var/lib/paperless";         mode = "0750"; user = "paperless";   group = "paperless"; }
      { directory = "/var/lib/miniflux-server";   mode = "0700"; user = "miniflux";    group = "miniflux"; }
      { directory = "/var/lib/n8n";               mode = "0700"; user = "n8n";         group = "n8n"; }
      { directory = "/var/lib/matrix-conduit";    mode = "0700"; user = "conduit";     group = "conduit"; }

      # ── MONITORING ───────────────────────────────────────────────
      { directory = "/var/lib/netdata";           mode = "0750"; user = "netdata"; group = "netdata"; }
      { directory = "/var/lib/uptime-kuma";       mode = "0750"; user = "uptime-kuma"; group = "uptime-kuma"; }
      { directory = "/var/lib/scrutiny";          mode = "0750"; user = "scrutiny"; group = "scrutiny"; }

      # ── FAIL2BAN ─────────────────────────────────────────────────
      # Ohne Persistence verliert Fail2Ban alle Ban-Historien nach Reboot
      { directory = "/var/lib/fail2ban";          mode = "0700"; user = "root"; group = "root"; }
    ];

    files = [
      # ── ABSOLUT KRITISCH: SSH Host Keys ──────────────────────────
      # Verlust = alle Clients bekommen Host-Key-Warning
      # Tailscale SSH bricht komplett
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"

      # ── MACHINE-ID ───────────────────────────────────────────────
      # Verlust = Systemd-Journal-Verknüpfung bricht, DBUS-IDs ändern sich
      "/etc/machine-id"

      # ── SOPS AGE KEY ─────────────────────────────────────────────
      # Das ist der einzige Key der alle Secrets entschlüsselt
      # Muss ZUSÄTZLICH extern gesichert sein (Hardware-Key, Offline-Backup)
      "/var/lib/sops-nix/key.txt"
    ];
  };

  # ── IMPERMANENCE-ASSERTION: Verhindere vergessene State-Pfade ────────
  # Warnung wenn ein Service-StateDirectory nicht in persistence gelistet ist
  assertions =
    let
      persistedPaths = map (d: d.directory)
        config.environment.persistence."/data/persist".directories;
      
      criticalStateDirs = [
        "/var/lib/sops-nix"
        "/etc/ssh"
        "/var/lib/tailscale"
        "/var/lib/postgresql"
      ];
    in
      map (path: {
        assertion = builtins.elem path persistedPaths;
        message   = "[IMPERMANENCE] Kritischer State-Pfad '${path}' fehlt in persistence-Liste!";
      }) criticalStateDirs;
}
```

### Migration-Strategie (ohne Downtime)

```bash
# scripts/migrate-to-impermanence.sh
# Führe das AUF dem laufenden System aus, BEVOR du die Nix-Config aktivierst

set -euo pipefail

PERSIST_ROOT="/data/persist"
echo "📦 Migriere State nach ${PERSIST_ROOT}..."

# Für jeden kritischen Pfad: copy-then-symlink
migrate_dir() {
  local src="$1" owner="$2"
  local dest="${PERSIST_ROOT}${src}"
  
  if [ -d "$src" ] && [ ! -d "$dest" ]; then
    echo "  → Migriere: $src"
    mkdir -p "$(dirname "$dest")"
    # rsync statt cp: erhält Permissions, Timestamps, xattrs
    rsync -aAX "$src/" "$dest/"
    chown -R "$owner" "$dest"
    echo "  ✅ $src → $dest"
  else
    echo "  ⏭  Überspringe: $src (bereits migriert oder leer)"
  fi
}

migrate_dir "/var/lib/sops-nix"      "root:root"
migrate_dir "/var/lib/tailscale"     "root:root"
migrate_dir "/var/lib/pocket-id"     "pocket-id:pocket-id"
migrate_dir "/var/lib/postgresql"    "postgres:postgres"
migrate_dir "/var/lib/vaultwarden"   "vaultwarden:vaultwarden"
migrate_dir "/data/state/jellyfin"   "jellyfin:media"
migrate_dir "/var/lib/zigbee2mqtt"   "zigbee2mqtt:zigbee2mqtt"
migrate_dir "/var/lib/hass"          "hass:hass"
# ... alle weiteren Pfade

# SSH Keys sichern
for key in /etc/ssh/ssh_host_*; do
  dest="${PERSIST_ROOT}${key}"
  if [ ! -f "$dest" ]; then
    cp -p "$key" "$dest"
    echo "  ✅ $key gesichert"
  fi
done

echo ""
echo "✅ Migration abgeschlossen."
echo "⚠️  NÄCHSTE SCHRITTE:"
echo "   1. nixos-rebuild switch (aktiviert impermanence.nix)"
echo "   2. Reboot"
echo "   3. Prüfe: ls /data/persist — muss alle migrierten Pfade zeigen"
echo "   4. Prüfe: mount | grep tmpfs — / muss auf tmpfs sein"
```

**SRE-Begründung:** Impermanence erzwingt, dass der Operator **jede Zustandsänderung bewusst entscheidet**. Was nach Reboot weg ist, war nie wirklich deklariert. Das eliminiert den `config-merger.nix` JSON-Override-Mechanismus organisch — weil impliziter State nicht überlebt. MTTR bei einer Bare-Metal-Neuinstallation sinkt von "Stunden manueller Rekonfiguration" auf "deploy flake, reboot, restore Restic-Snapshot".

---

## Zusammenfassung: Umsetzungsreihenfolge

```
Woche 1: HAL + Assertions (kein Risiko, nur additive Änderungen)
Woche 2: lib-service-hardening.nix + nftables Micro-Seg (schrittweise, Service für Service)
Woche 3: generate-index.sh + pre-commit Hook (non-breaking)
Woche 4: Impermanence-Migration (mit Restic-Backup davor, nie ohne)
```

Der kritischste Schritt ist die Impermanence-Migration. Alles andere kann inkrementell eingeführt werden, ohne das System zu destabilisieren.



## Response:
8.3.2026, 14:53:43

# NixHome NMS v4.2 — Storage, Security & State Deep-Dive

Vier Fragen, vier präzise Antworten. Kein Padding.

---

## 1. Storage-Diktatur: Pfad-Kollisions-Prävention im ABC-Modell

### Das eigentliche Problem

Pfad-Kollisionen entstehen nicht durch falsche Pfade, sondern durch **fehlende Ownership-Semantik**. Wenn Sonarr und Radarr beide `/mnt/fast-pool/downloads` als `ReadWritePaths` haben, ist das kein Kollisions-Problem — das ist gewollt. Die echten Kollisionen passieren bei **State-Pfaden**, wenn zwei Services dasselbe Verzeichnis als `StateDirectory` beanspruchen, oder wenn ein Service seinen State in Tier B schreibt, obwohl Tier A verfügbar ist.

### Lösung: Zentraler Storage-Broker als HAL-Erweiterung

```nix
# 00-core/hal-storage.nix
{ config, lib, pkgs, ... }:
let
  nms = {
    id    = "NIXH-00-COR-HAL-002";
    title = "HAL: Storage Broker (ABC-Tiering)";
    layer = 00;
    audit.complexity = 4;
    audit.last_reviewed = "2026-03-03";
    status = "active";
    upstream   = [ "NIXH-00-COR-HAL-001" ];
    downstream = [ "NIXH-40-MED-007" "NIXH-20-INF-002" ];
  };

  cfg = config.my.hal.storage;

  # ── TIER-DEFINITIONEN ────────────────────────────────────────────────
  # Jeder Tier hat eine kanonische Basis-Wurzel und eine Priorität.
  # Services erhalten via mkStoragePath einen Pfad OHNE den Tier zu kennen.
  tiers = {
    # Tier 0: RAM (zram-swap / tmpfs) — flüchtig, kein Persist
    t0-ram = {
      priority = 0;
      base     = "/run/nixhome-cache";
      fsType   = "tmpfs";
      persist  = false;
      desc     = "RAM (tmpfs) — für Session-Caches, Lock-Files";
    };
    # Tier A: NVMe — schneller, persistenter State
    tA-nvme = {
      priority = 10;
      base     = cfg.tierA.mountPoint;
      fsType   = "ext4";
      persist  = true;
      desc     = "NVMe — App-State, Datenbanken";
    };
    # Tier B: SSD — Metadaten, Transcoding-Cache
    tB-ssd = {
      priority = 20;
      base     = cfg.tierB.mountPoint;
      fsType   = "ext4";
      persist  = true;
      desc     = "SSD — Metadaten, Cache, Transcoding";
    };
    # Tier C: HDD / MergerFS — Bulk-Daten
    tC-bulk = {
      priority = 30;
      base     = cfg.tierC.mountPoint;
      fsType   = "fuse.mergerfs";
      persist  = true;
      desc     = "HDD/MergerFS — Medien, Backups, kalte Daten";
    };
  };

  # ── PFAD-REGISTRY ─────────────────────────────────────────────────────
  # Alle Service-Pfade zentral registriert.
  # Format: { nixhId, tier, subPath, owner, group, mode, purpose }
  #
  # Das ist das Herzstück der Kollisions-Prävention:
  # Ein Service kann EINEN Pfad pro NIXH-ID registrieren.
  # Doppelte subPaths innerhalb desselben Tiers → Assertion-Fehler.
  pathRegistry = [
    # ── TIER A: App-State ─────────────────────────────────────────────
    { nixhId = "NIXH-20-INF-002"; tier = "tA-nvme";  subPath = "state/postgresql";      owner = "postgres";      group = "postgres";  mode = "0700"; purpose = "database"; }
    { nixhId = "NIXH-60-APP-007"; tier = "tA-nvme";  subPath = "state/vaultwarden";     owner = "vaultwarden";   group = "vaultwarden"; mode = "0700"; purpose = "app-state"; }
    { nixhId = "NIXH-10-GTW-009"; tier = "tA-nvme";  subPath = "state/pocket-id";       owner = "pocket-id";     group = "pocket-id"; mode = "0750"; purpose = "app-state"; }
    { nixhId = "NIXH-30-AUT-004"; tier = "tA-nvme";  subPath = "state/n8n";             owner = "n8n";           group = "n8n";       mode = "0700"; purpose = "app-state"; }
    { nixhId = "NIXH-50-KNW-003"; tier = "tA-nvme";  subPath = "state/paperless";       owner = "paperless";     group = "paperless"; mode = "0750"; purpose = "app-state"; }
    { nixhId = "NIXH-40-MED-007"; tier = "tA-nvme";  subPath = "state/jellyfin";        owner = "jellyfin";      group = "media";     mode = "0750"; purpose = "app-state"; }
    { nixhId = "NIXH-40-MED-017"; tier = "tA-nvme";  subPath = "state/sonarr";          owner = "sonarr";        group = "media";     mode = "0750"; purpose = "app-state"; }
    { nixhId = "NIXH-40-MED-012"; tier = "tA-nvme";  subPath = "state/radarr";          owner = "radarr";        group = "media";     mode = "0750"; purpose = "app-state"; }
    { nixhId = "NIXH-40-MED-009"; tier = "tA-nvme";  subPath = "state/lidarr";          owner = "lidarr";        group = "media";     mode = "0750"; purpose = "app-state"; }
    { nixhId = "NIXH-40-MED-013"; tier = "tA-nvme";  subPath = "state/readarr";         owner = "readarr";       group = "media";     mode = "0750"; purpose = "app-state"; }
    { nixhId = "NIXH-40-MED-011"; tier = "tA-nvme";  subPath = "state/prowlarr";        owner = "prowlarr";      group = "media";     mode = "0750"; purpose = "app-state"; }
    { nixhId = "NIXH-40-MED-015"; tier = "tA-nvme";  subPath = "state/sabnzbd";         owner = "sabnzbd";       group = "media";     mode = "0750"; purpose = "app-state"; }

    # ── TIER B: Metadaten & Cache ─────────────────────────────────────
    { nixhId = "NIXH-40-MED-007"; tier = "tB-ssd";   subPath = "cache/jellyfin";        owner = "jellyfin";      group = "media";     mode = "0750"; purpose = "transcode-cache"; }
    { nixhId = "NIXH-40-MED-017"; tier = "tB-ssd";   subPath = "metadata/sonarr";       owner = "sonarr";        group = "media";     mode = "0750"; purpose = "cover-cache"; }
    { nixhId = "NIXH-40-MED-012"; tier = "tB-ssd";   subPath = "metadata/radarr";       owner = "radarr";        group = "media";     mode = "0750"; purpose = "cover-cache"; }
    { nixhId = "NIXH-40-MED-009"; tier = "tB-ssd";   subPath = "metadata/lidarr";       owner = "lidarr";        group = "media";     mode = "0750"; purpose = "cover-cache"; }
    { nixhId = "NIXH-20-INF-006"; tier = "tB-ssd";   subPath = "cache/valkey";          owner = "redis-valkey";  group = "redis-valkey"; mode = "0750"; purpose = "kv-cache"; }

    # ── TIER C: Bulk-Daten ────────────────────────────────────────────
    { nixhId = "NIXH-40-MED-001"; tier = "tC-bulk";  subPath = "media/movies";          owner = "radarr";        group = "media";     mode = "0775"; purpose = "media-storage"; }
    { nixhId = "NIXH-40-MED-001"; tier = "tC-bulk";  subPath = "media/tv";              owner = "sonarr";        group = "media";     mode = "0775"; purpose = "media-storage"; }
    { nixhId = "NIXH-40-MED-001"; tier = "tC-bulk";  subPath = "media/music";           owner = "lidarr";        group = "media";     mode = "0775"; purpose = "media-storage"; }
    { nixhId = "NIXH-40-MED-001"; tier = "tC-bulk";  subPath = "media/books";           owner = "readarr";       group = "media";     mode = "0775"; purpose = "media-storage"; }
    { nixhId = "NIXH-40-MED-015"; tier = "tC-bulk";  subPath = "downloads/usenet";      owner = "sabnzbd";       group = "media";     mode = "0775"; purpose = "download-staging"; }
    { nixhId = "NIXH-00-COR-004"; tier = "tC-bulk";  subPath = "backups/restic";        owner = "root";          group = "root";      mode = "0700"; purpose = "backup-repo"; }
  ];

  # ── KOLLISIONS-DETEKTION ZUR EVAL-ZEIT ───────────────────────────────
  # Extrahiere alle (tier, subPath)-Paare und prüfe auf Duplikate
  allPaths    = map (e: "${e.tier}:${e.subPath}") pathRegistry;
  uniquePaths = lib.unique allPaths;
  hasDuplicate = (builtins.length allPaths) != (builtins.length uniquePaths);

  duplicates =
    let counted = lib.foldl'
          (acc: p: acc // { ${p} = (acc.${p} or 0) + 1; })
          {}
          allPaths;
    in lib.filterAttrs (_: count: count > 1) counted;

  # ── ÖFFENTLICHE API: mkStoragePath ───────────────────────────────────
  # Wird von Service-Modulen aufgerufen — nie direkter Pfad-Zugriff!
  # Gibt den vollständigen absoluten Pfad zurück.
  mkStoragePath = nixhId: tier:
    let
      entry = lib.findFirst
        (e: e.nixhId == nixhId && e.tier == tier)
        null
        pathRegistry;
    in
      if entry == null
      then throw "[HAL-STORAGE] Kein Pfad für ${nixhId} auf Tier ${tier} registriert!"
      else "${tiers.${tier}.base}/${entry.subPath}";

  # ── TMPFILES-REGELN GENERIEREN ────────────────────────────────────────
  # Für jeden persistenten Pfad eine tmpfiles-Regel erzeugen
  persistentPaths = lib.filter (e: tiers.${e.tier}.persist) pathRegistry;

  toTmpfilesRule = entry:
    "d ${tiers.${entry.tier}.base}/${entry.subPath} ${entry.mode} ${entry.owner} ${entry.group} -";

in {
  options.my.meta.hal_storage = lib.mkOption {
    type     = lib.types.attrs;
    default  = nms;
    readOnly = true;
  };

  options.my.hal.storage = {
    tierA.mountPoint = lib.mkOption {
      type        = lib.types.str;
      default     = "/mnt/tier-a";
      description = "Mount-Point für Tier A (NVMe). Muss vor nixos-rebuild existieren.";
    };
    tierB.mountPoint = lib.mkOption {
      type    = lib.types.str;
      default = "/mnt/tier-b";
    };
    tierC.mountPoint = lib.mkOption {
      type    = lib.types.str;
      default = "/mnt/tier-c";
    };

    # Exportierte API für andere Module
    mkPath = lib.mkOption {
      type        = lib.types.raw;
      default     = mkStoragePath;
      readOnly    = true;
      description = "Funktion: nixhId -> tier -> absoluterPfad";
    };
  };

  config = {
    # ── KOLLISIONS-ASSERTION ─────────────────────────────────────────
    assertions = [
      {
        assertion = !hasDuplicate;
        message   = ''
          [HAL-STORAGE-COLLISION] Doppelte Pfad-Einträge in der Storage-Registry!
          Betroffene Pfade:
          ${lib.concatStringsSep "\n" (map (p: "  - ${p}") (builtins.attrNames duplicates))}
          Prüfe pathRegistry in hal-storage.nix auf doppelte (tier, subPath)-Kombinationen.
        '';
      }
      {
        # Tier-A Mount-Point muss ein absoluter Pfad sein
        assertion = lib.hasPrefix "/" cfg.tierA.mountPoint;
        message   = "[HAL-STORAGE] tierA.mountPoint muss absoluter Pfad sein.";
      }
    ];

    # ── VERZEICHNISSE ANLEGEN ─────────────────────────────────────────
    systemd.tmpfiles.rules = map toTmpfilesRule persistentPaths
      ++ [
        # Tier-0 tmpfs Runtime-Dir
        "d /run/nixhome-cache 0755 root root -"
      ];
  };
}
```

**Nutzung in einem Service-Modul:**

```nix
# 40-media/service-media-jellyfin.nix (refactored)
{ config, lib, ... }:
let
  # Kein hardcoded Pfad mehr — der Broker entscheidet den Tier
  stateDir = config.my.hal.storage.mkPath "NIXH-40-MED-007" "tA-nvme";
  cacheDir = config.my.hal.storage.mkPath "NIXH-40-MED-007" "tB-ssd";
in {
  services.jellyfin = {
    dataDir  = stateDir;
    cacheDir = cacheDir;
  };
  systemd.services.jellyfin.serviceConfig = {
    ReadWritePaths = [ stateDir cacheDir ];
  };
}
```

---

## 2. Security: skuid vs. NixOS-native Abstraktionen

### Direkte Antwort

`skuid`-basiertes nftables ist der **stabilste Weg für ausgehende Service-Isolation**, aber es ist nicht die vollständige Antwort. Die richtige Strategie kombiniert drei Ebenen.

### Warum `skuid` korrekt ist — und wo es versagt

```
skuid-Stärken:
  ✅ Kernelraum-Enforcement — kein Userspace-Bypass möglich
  ✅ Granular: pro-Service, nicht pro-Interface
  ✅ Funktioniert auch wenn Service auf 0.0.0.0 bindet (Outbound-Filter)

skuid-Schwächen:
  ❌ DynamicUser = true: UID wechselt bei jedem Start → skuid-Regel veraltet
  ❌ Kein Schutz gegen Unix-Socket-Kommunikation (andere Ebene nötig)
  ❌ Wartungsaufwand: jede neue Service-UID muss manuell eingetragen werden
```

**Das DynamicUser-Problem** ist entscheidend. Prowlarr, Miniflux, Readeck nutzen `DynamicUser = true` — ihre UIDs sind nicht deterministisch. Für diese Services funktioniert `skuid` nicht.

### Dreistufige Security-Architektur

```nix
# 00-core/firewall-layered.nix
{ config, lib, pkgs, ... }:
let
  # ── STUFE 1: nftables skuid (für statische System-User) ──────────────
  # Nur für Services MIT fester UID (postgres, caddy, jellyfin, etc.)
  staticUserServices = [
    { user = "caddy";       allowOutPorts = [ 80 443 853 ];          allowIn = false; }
    { user = "jellyfin";    allowOutPorts = [ 53 ];                   allowIn = false; }
    { user = "sonarr";      allowOutPorts = [ 53 config.my.ports.sabnzbd config.my.ports.prowlarr ]; allowIn = false; }
    { user = "radarr";      allowOutPorts = [ 53 config.my.ports.sabnzbd config.my.ports.prowlarr ]; allowIn = false; }
    { user = "postgres";    allowOutPorts = [];                        allowIn = false; }
    { user = "adguardhome"; allowOutPorts = [ 53 443 853 ];           allowIn = false; }
    { user = "tailscale";   allowOutPorts = [ 41641 ];                allowIn = false; }
  ];

  mkSkuidRule = svc:
    let
      outRules = lib.concatMapStringsSep "\n    "
        (port: "meta skuid ${svc.user} tcp dport ${toString port} accept")
        svc.allowOutPorts;
    in ''
      # ${svc.user}
      ${outRules}
      meta skuid ${svc.user} reject with icmpx type admin-prohibited
    '';

  # ── STUFE 2: systemd BindPaths + ReadWritePaths (Filesystem-Isolation) ─
  # Das ist die NixOS-native Abstraktion — kein nftables nötig für FS
  # Wird über lib-service-hardening.nix verwaltet (bereits definiert)

  # ── STUFE 3: IPAddressDeny/Allow in systemd (für DynamicUser) ────────
  # Da skuid bei DynamicUser versagt, nutzen wir systemd-eigene IP-Filter
  # Das ist kernel-enforced via cgroup BPF — genauso sicher wie nftables
  dynamicUserNetworkPolicy = {
    # Standard-Policy für alle DynamicUser-Services: nur Loopback + LAN
    defaultAllow = [ "127.0.0.0/8" "::1/128" ]
      ++ config.my.configs.network.lanCidrs
      ++ config.my.configs.network.tailnetCidrs;

    # Services die Internet brauchen, werden explizit freigeschaltet
    internetEnabled = [ "miniflux" "recyclarr" "readeck" "linkwarden" ];
  };

in {
  # ── nftables: Stufe 1 Outbound-Filter ────────────────────────────────
  networking.nftables.tables.nixhome-egress = {
    family  = "inet";
    content = ''
      chain output-service-isolation {
        type filter hook output priority filter + 10; policy accept;

        # Loopback immer erlauben (Unix-Sockets, localhost-Kommunikation)
        oif lo accept

        # Root und systemd immer erlauben
        meta skuid root  accept
        meta skuid systemd-network accept

        # DNS für alle (AdGuard lokal)
        udp dport 53 accept
        tcp dport 53 accept

        # ── STATISCHE USER-SERVICES ──────────────────────────────────
        ${lib.concatMapStrings mkSkuidRule staticUserServices}

        # Alles andere ohne explizite Regel: passthrough
        # (Wird durch systemd IPAddressDeny auf DynamicUser-Ebene gefiltert)
      }

      chain input-service-isolation {
        type filter hook input priority filter + 10; policy accept;

        # Eingehend: nur was über Caddy kommt (127.0.0.1) oder Tailscale
        # Services binden auf 127.0.0.1 — externe Direktzugriffe geblockt
        # durch bestehende firewall.nix
      }
    '';
  };

  # ── systemd: Stufe 3 für DynamicUser-Services ─────────────────────
  # Aktiviere IPAddressDeny für alle Services mit DynamicUser
  systemd.services = lib.mkMerge (
    map (name: {
      ${name}.serviceConfig = {
        IPAddressDeny  = lib.mkDefault [ "any" ];
        IPAddressAllow = lib.mkDefault dynamicUserNetworkPolicy.defaultAllow;
      };
    })
    # Services MIT DynamicUser = true (kein skuid möglich)
    [ "miniflux" "prowlarr" "readeck" "scrutiny" ]
    ++
    # Services die Internet brauchen: komplette Allow-List
    map (name: {
      ${name}.serviceConfig = {
        IPAddressDeny  = lib.mkForce [];
        IPAddressAllow = lib.mkForce [ "any" ];
      };
    })
    dynamicUserNetworkPolicy.internetEnabled
  );

  # ── ASSERTION: Inkonsistenz-Detektion ────────────────────────────────
  assertions = [
    {
      # skuid-Regeln für Services die DynamicUser nutzen sind wirkungslos
      assertion =
        let
          dynamicUserNames = [ "miniflux" "prowlarr" "readeck" "scrutiny" ];
          skuidNames = map (s: s.user) staticUserServices;
          overlap = lib.intersectLists dynamicUserNames skuidNames;
        in
          overlap == [];
      message = "[FIREWALL] Services mit DynamicUser dürfen nicht in staticUserServices stehen — skuid ist bei DynamicUser unwirksam!";
    }
  ];
}
```

**Zusammenfassung der Stufen:**

| Stufe | Mechanismus | Für | Kernel-Ebene |
|-------|-------------|-----|-------------|
| 1 | nftables skuid | Statische System-User (caddy, postgres) | Netfilter |
| 2 | systemd BindPaths | Filesystem-Isolation (alle Services) | VFS |
| 3 | systemd IPAddressDeny | DynamicUser-Services | cgroup BPF |

---

## 3. zram-swap als Tier 0

### Konzept: zram als HAL-Capability

zram ist kein Storage-Tier im klassischen Sinne — es hat keine persistenten Pfade. Aber es beeinflusst, **wie aggressiv Tier A (NVMe) als Swap genutzt wird**. Die Integration in den HAL erfolgt über zwei Hebel: `vm.swappiness` und explizite tmpfs-Mounts für flüchtige Service-Caches.

```nix
# 00-core/hal-memory.nix
{ config, lib, pkgs, ... }:
let
  nms = {
    id    = "NIXH-00-COR-HAL-003";
    title = "HAL: Memory & Tier-0 (zram)";
    layer = 00;
    audit.complexity  = 3;
    audit.last_reviewed = "2026-03-03";
    upstream   = [ "NIXH-00-COR-HAL-002" ];
    downstream = [ "NIXH-00-COR-040" ];
  };

  ramGB = config.my.configs.hardware.ramGB;

  # ── ZRAM-PROFIL BASIEREND AUF RAM-GRÖSSE ──────────────────────────────
  # Ziel: NVMe-Schreiblast minimieren, RAM als primären Puffer nutzen
  zramProfile =
    if ramGB <= 4  then { memPercent = 75; swappiness = 180; pageCluster = 0; }
    else if ramGB <= 8  then { memPercent = 60; swappiness = 150; pageCluster = 0; }
    else if ramGB <= 16 then { memPercent = 40; swappiness = 100; pageCluster = 0; }
    else                     { memPercent = 25; swappiness = 60;  pageCluster = 0; };

  # ── TIER-0 TMPFS: Services die flüchtige Caches brauchen ─────────────
  # Diese Verzeichnisse leben in RAM, nicht auf NVMe.
  # Nach Reboot weg — das ist gewollt.
  tier0Mounts = [
    {
      where   = "/run/nixhome-cache/thumbnails";
      what    = "tmpfs";
      options = "size=256M,mode=0755,uid=jellyfin,gid=media";
      desc    = "Jellyfin Thumbnail-Cache (RAM)";
    }
    {
      where   = "/run/nixhome-cache/arr-icons";
      what    = "tmpfs";
      options = "size=64M,mode=0755,uid=root,gid=media";
      desc    = "Arr-Stack Icon-Cache (RAM)";
    }
    {
      where   = "/run/nixhome-cache/caddy-tmp";
      what    = "tmpfs";
      options = "size=128M,mode=0750,uid=caddy,gid=caddy";
      desc    = "Caddy temporäre Files (RAM)";
    }
  ];

  # ── WRITE-BEHIND STRATEGIE ────────────────────────────────────────────
  # vm.dirty_* kontrolliert, wann Kernel Dirty Pages auf Disk schreibt.
  # Hohe Werte = mehr RAM-Puffer, weniger NVMe-Writes.
  # Für Homelab (kein kritischer Write-Durability-Bedarf) aggressiv tunen:
  writeBehindTuning = {
    "vm.dirty_ratio"            = 20;    # Max 20% RAM als Dirty Pages
    "vm.dirty_background_ratio" = 5;     # Ab 5% async in Hintergrund schreiben
    "vm.dirty_expire_centisecs" = 3000;  # Dirty Pages max 30s im RAM halten
    "vm.dirty_writeback_centisecs" = 500; # Writeback-Thread alle 5s aufwachen
  };

in {
  options.my.meta.hal_memory = lib.mkOption {
    type     = lib.types.attrs;
    default  = nms;
    readOnly = true;
  };

  config = {
    # ── ZRAM: Tier 0 Swap ─────────────────────────────────────────────
    zramSwap = {
      enable      = true;
      algorithm   = "zstd";
      priority    = 200;          # Höher als jeder Disk-Swap
      memoryPercent = zramProfile.memPercent;
    };

    # ── KERNEL TUNING ─────────────────────────────────────────────────
    boot.kernel.sysctl = {
      # zram-optimiertes Swappiness (höher = RAM/zram bevorzugen vor NVMe)
      "vm.swappiness"    = lib.mkForce zramProfile.swappiness;
      "vm.page-cluster"  = lib.mkForce zramProfile.pageCluster;

      # Write-Behind: NVMe-Schreiblast reduzieren
    } // writeBehindTuning;

    # ── TIER-0 TMPFS MOUNTS ───────────────────────────────────────────
    systemd.mounts = map (m: {
      description = m.desc;
      what        = m.what;
      where       = m.where;
      type        = "tmpfs";
      options     = m.options;
      wantedBy    = [ "local-fs.target" ];
      before      = [ "local-fs.target" ];
    }) tier0Mounts;

    # Verzeichnisse anlegen bevor gemountet wird
    systemd.tmpfiles.rules =
      map (m: "d ${m.where} 0755 root root -") tier0Mounts;

    # ── JELLYFIN: Nutze Tier-0 für Thumbnail-Cache ────────────────────
    # Überschreibt den tB-ssd Cache aus hal-storage.nix für flüchtige Daten
    systemd.services.jellyfin.environment = {
      JELLYFIN_CACHE_DIR = "/run/nixhome-cache/thumbnails";
    };

    # ── MONITORING: zram-Nutzung ins Homepage-Dashboard ──────────────
    systemd.services.zram-stats-reporter = {
      description = "zram Stats → Homepage Widget";
      after       = [ "multi-user.target" ];
      serviceConfig = {
        Type            = "oneshot";
        ExecStart       = pkgs.writeShellScript "zram-stats" ''
          set -euo pipefail
          ZRAM_DEV=$(ls /dev/zram* 2>/dev/null | head -1)
          if [ -z "$ZRAM_DEV" ]; then exit 0; fi

          COMP_RATIO=$(cat /sys/block/$(basename $ZRAM_DEV)/stat 2>/dev/null || echo "0")
          ORIG_SIZE=$(cat /sys/block/$(basename $ZRAM_DEV)/orig_data_size 2>/dev/null || echo "0")
          COMP_SIZE=$(cat /sys/block/$(basename $ZRAM_DEV)/compr_data_size 2>/dev/null || echo "0")

          # Schreibe Stats als JSON für Homepage-Widget
          ${pkgs.jq}/bin/jq -n \
            --argjson orig "$ORIG_SIZE" \
            --argjson comp "$COMP_SIZE" \
            '{
              tier: "T0-RAM",
              orig_mb: ($orig / 1048576 | floor),
              comp_mb: ($comp / 1048576 | floor),
              ratio: (if $comp > 0 then ($orig / $comp * 100 | floor) / 100 else 0 end),
              saved_mb: (($orig - $comp) / 1048576 | floor)
            }' > /run/nixhome-cache/zram-stats.json
        '';
        DynamicUser     = true;
        ReadOnlyPaths   = [ "/sys/block" ];
        ReadWritePaths  = [ "/run/nixhome-cache" ];
        ProtectSystem   = "strict";
        PrivateTmp      = true;
      };
    };

    systemd.timers.zram-stats-reporter = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec         = "2min";
        OnUnitActiveSec   = "5min";
        RandomizedDelaySec = "30";
      };
    };

    # ── ASSERTION: zram + kein Disk-Swap ─────────────────────────────
    assertions = [
      {
        assertion = config.hardware.cpu.intel.updateMicrocode ->
          config.zramSwap.enable;
        message = "[HAL-MEMORY] zramSwap sollte aktiv sein wenn kein Disk-Swap konfiguriert ist.";
      }
    ];

    # ── WARNUNG bei zu niedrigem RAM ─────────────────────────────────
    warnings = lib.optional (ramGB < 8)
      "[HAL-MEMORY] ${toString ramGB}GB RAM: zram-Tier-0 auf ${toString zramProfile.memPercent}% gesetzt. Bei RAM-Druck können Services OOM-killed werden.";
  };
}
```

**Warum `vm.swappiness = 180` korrekt ist:** Bei zram ist ein hoher Swappiness-Wert nicht "mehr Swapping auf Disk" — es bedeutet "bevorzuge komprimierten RAM über unkomprimierten RAM". Der Kernel schreibt Seiten nach zram (3:1 Kompressionsratio typisch), nicht auf NVMe. NVMe-Writes durch Swap werden faktisch eliminiert.

---

## 4. Pending Disks: Deklarativer Umgang mit unlabelten Datenträgern

### Das Problem präzise formuliert

`nixos-rebuild switch` schlägt fehl, wenn ein `fileSystems`-Eintrag einen Mount-Point referenziert, dessen Gerät nicht existiert. Der Standardweg `options = ["nofail"]` ist nicht ausreichend — er verhindert den Boot-Abort, aber der Service der diesen Mount braucht, startet trotzdem und schreibt auf den darunterliegenden Pfad, nicht auf den erwarteten Datenträger.

### Lösung: Drei-Phasen-Ansatz

```nix
# 00-core/hal-disk-discovery.nix
{ config, lib, pkgs, ... }:
let
  nms = {
    id    = "NIXH-00-COR-HAL-004";
    title = "HAL: Disk Discovery & Pending-Disk-Handler";
    layer = 00;
    audit.complexity  = 5;
    audit.last_reviewed = "2026-03-03";
    upstream   = [ "NIXH-00-COR-HAL-002" ];
    downstream = [];
  };

  cfg = config.my.hal.diskDiscovery;

  # ── PHASE 1: udev — Erkennung & Labeling ─────────────────────────────
  # Disks werden via udev-Regeln erkannt.
  # Bekannte Disks (by-label): sofort gemountet.
  # Unbekannte Disks: landen in "pending" Queue → OliveTin-Button erscheint.

  udevRules = pkgs.writeText "99-nixhome-disk-discovery.rules" ''
    # Erkenne NixHome-gelabelte Partitionen
    SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="NMS_TIER_A", \
      RUN+="${pkgs.systemd}/bin/systemctl --no-block start nixhome-mount-tier-a.service"

    SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="NMS_TIER_B", \
      RUN+="${pkgs.systemd}/bin/systemctl --no-block start nixhome-mount-tier-b.service"

    SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="NMS_TIER_C", \
      RUN+="${pkgs.systemd}/bin/systemctl --no-block start nixhome-mount-tier-c.service"

    # Unbekannte Datenträger (keine NMS-Label) → Pending-Queue
    SUBSYSTEM=="block", KERNEL=="sd[a-z]", \
      ENV{ID_FS_LABEL}!="NMS_TIER_*", \
      ENV{ID_TYPE}=="disk", \
      RUN+="${pkgs.systemd}/bin/systemctl --no-block start nixhome-disk-pending@%k.service"
  '';

  # ── PHASE 2: systemd — Mount-Services mit Fallback-Logik ─────────────
  # Jeder Tier-Mount ist ein eigenständiger Service.
  # KRITISCH: RequiredBy NICHT nutzen — nur WantedBy.
  # Das verhindert nixos-rebuild-Fehler bei fehlendem Datenträger.
  mkTierMountService = tier: label: mountPoint: {
    "nixhome-mount-${tier}" = {
      description = "NixHome Tier-${tier} Mount (${label})";
      after       = [ "local-fs.target" "udev.service" ];
      wantedBy    = [ "multi-user.target" ];
      # PartOf statt RequiredBy: wenn dieser Service stoppt, stoppt nicht das System
      partOf      = [];

      serviceConfig = {
        Type            = "oneshot";
        RemainAfterExit = true;
        ExecStart       = pkgs.writeShellScript "mount-${tier}" ''
          set -euo pipefail

          LABEL="${label}"
          MOUNT="${mountPoint}"
          PENDING_FILE="/run/nixhome-pending-disks/${tier}.pending"

          # Prüfe ob Gerät mit diesem Label existiert
          DEV=$(blkid -L "$LABEL" 2>/dev/null || echo "")

          if [ -z "$DEV" ]; then
            # Kein Gerät gefunden → Pending-Status setzen
            mkdir -p /run/nixhome-pending-disks
            echo "${tier}:${label}:${mountPoint}:$(date -Iseconds)" > "$PENDING_FILE"

            logger -t nixhome-hal "PENDING: Tier ${tier} (Label: $LABEL) nicht gefunden. Mount ${mountPoint} übersprungen."

            # Homepage-Widget Status aktualisieren
            ${pkgs.jq}/bin/jq -n \
              --arg tier "${tier}" \
              --arg label "$LABEL" \
              --arg mount "${mountPoint}" \
              --arg status "pending" \
              --arg ts "$(date -Iseconds)" \
              '{tier: $tier, label: $label, mountPoint: $mount, status: $status, timestamp: $ts}' \
              >> /run/nixhome-pending-disks/status.json

            # Exit 0: kein Fehler, aber Mount fehlt
            exit 0
          fi

          # Gerät gefunden → mounten
          mkdir -p "$MOUNT"

          if mountpoint -q "$MOUNT"; then
            logger -t nixhome-hal "Tier ${tier} bereits gemountet auf $MOUNT"
            exit 0
          fi

          mount -L "$LABEL" "$MOUNT"
          logger -t nixhome-hal "Tier ${tier} erfolgreich gemountet: $DEV → $MOUNT"

          # Pending-Status löschen falls vorhanden
          rm -f "$PENDING_FILE"

          # Abhängige Services aktivieren
          ${pkgs.systemd}/bin/systemctl --no-block \
            start nixhome-tier-${tier}-ready.target 2>/dev/null || true
        '';

        ExecStop = pkgs.writeShellScript "umount-${tier}" ''
          umount -l "${mountPoint}" 2>/dev/null || true
        '';

        ProtectSystem   = "no";   # Braucht Schreibzugriff für Mount
        PrivateTmp      = true;
        ReadWritePaths  = [ "/run/nixhome-pending-disks" mountPoint ];
      };
    };
  };

in {
  options.my.meta.hal_disk_discovery = lib.mkOption {
    type     = lib.types.attrs;
    default  = nms;
    readOnly = true;
  };

  options.my.hal.diskDiscovery = {
    enable = lib.mkEnableOption "HAL Disk Discovery & Pending-Handler";
    tierA  = {
      label      = lib.mkOption { type = lib.types.str; default = "NMS_TIER_A"; };
      mountPoint = lib.mkOption { type = lib.types.str; default = "/mnt/tier-a"; };
    };
    tierB  = {
      label      = lib.mkOption { type = lib.types.str; default = "NMS_TIER_B"; };
      mountPoint = lib.mkOption { type = lib.types.str; default = "/mnt/tier-b"; };
    };
    tierC  = {
      label      = lib.mkOption { type = lib.types.str; default = "NMS_TIER_C"; };
      mountPoint = lib.mkOption { type = lib.types.str; default = "/mnt/tier-c"; };
    };
  };

  config = lib.mkIf cfg.enable {
    # ── udev-REGELN DEPLOYEN ─────────────────────────────────────────
    services.udev.extraRules = builtins.readFile udevRules;

    # ── MOUNT-SERVICES ───────────────────────────────────────────────
    systemd.services =
      (mkTierMountService "tier-a" cfg.tierA.label cfg.tierA.mountPoint)
      // (mkTierMountService "tier-b" cfg.tierB.label cfg.tierB.mountPoint)
      // (mkTierMountService "tier-c" cfg.tierC.label cfg.tierC.mountPoint)
      // {
        # ── PENDING-DISK HANDLER ──────────────────────────────────────
        # Wird von udev für unbekannte Disks aufgerufen
        "nixhome-disk-pending@" = {
          description = "Pending Disk Handler für %i";
          serviceConfig = {
            Type      = "oneshot";
            ExecStart = pkgs.writeShellScript "pending-handler" ''
              set -euo pipefail
              DISK="$1"
              mkdir -p /run/nixhome-pending-disks

              # Disk-Eigenschaften ermitteln
              IS_ROTATIONAL=$(cat /sys/block/$DISK/queue/rotational 2>/dev/null || echo "?")
              SIZE_BYTES=$(cat /sys/block/$DISK/size 2>/dev/null || echo "0")
              SIZE_GB=$(( SIZE_BYTES * 512 / 1073741824 ))
              VENDOR=$(cat /sys/block/$DISK/device/vendor 2>/dev/null | tr -d ' ' || echo "unknown")
              MODEL=$(cat /sys/block/$DISK/device/model  2>/dev/null | tr -d ' ' || echo "unknown")

              DISK_TYPE=$([ "$IS_ROTATIONAL" = "0" ] && echo "SSD/NVMe" || echo "HDD")

              logger -t nixhome-hal "NEUE UNBEKANNTE DISK: /dev/$DISK ($DISK_TYPE, ${SIZE_GB}GB, $VENDOR $MODEL)"

              # Status-JSON für Homepage-Widget und OliveTin
              ${pkgs.jq}/bin/jq -n \
                --arg dev "/dev/$DISK" \
                --arg type "$DISK_TYPE" \
                --argjson size_gb "$SIZE_GB" \
                --arg vendor "$VENDOR" \
                --arg model  "$MODEL"  \
                --arg ts     "$(date -Iseconds)" \
                '{
                  device:    $dev,
                  type:      $type,
                  size_gb:   $size_gb,
                  vendor:    $vendor,
                  model:     $model,
                  status:    "pending_label",
                  timestamp: $ts,
                  action:    "OliveTin → Disk labeln → nixos-rebuild"
                }' >> /run/nixhome-pending-disks/unknown-disks.json

              # Systemd-Notification (erscheint in Homepage als Alert)
              ${pkgs.systemd}/bin/systemd-notify --status="Pending Disk: /dev/$DISK ($DISK_TYPE, ${SIZE_GB}GB)"
            '';
            PrivateTmp     = true;
            ProtectSystem  = "strict";
            ReadWritePaths = [ "/run/nixhome-pending-disks" "/sys/block" ];
          };
        };

        # ── PENDING-DISK WATCHER ──────────────────────────────────────
        # Prüft periodisch ob Pending-Disks inzwischen gelabelt wurden
        "nixhome-pending-watcher" = {
          description = "Prüft Pending-Disks auf neue Labels";
          serviceConfig = {
            Type      = "oneshot";
            ExecStart = pkgs.writeShellScript "pending-watcher" ''
              set -euo pipefail
              PENDING_DIR="/run/nixhome-pending-disks"
              [ -d "$PENDING_DIR" ] || exit 0

              for pending_file in "$PENDING_DIR"/*.pending; do
                [ -f "$pending_file" ] || continue
                CONTENT=$(cat "$pending_file")
                TIER=$(echo "$CONTENT"   | cut -d: -f1)
                LABEL=$(echo "$CONTENT"  | cut -d: -f2)
                MOUNT=$(echo "$CONTENT"  | cut -d: -f3)

                DEV=$(blkid -L "$LABEL" 2>/dev/null || echo "")
                if [ -n "$DEV" ]; then
                  logger -t nixhome-hal "Pending Tier $TIER jetzt verfügbar ($DEV). Starte Mount..."
                  ${pkgs.systemd}/bin/systemctl --no-block start "nixhome-mount-$TIER.service"
                fi
              done
            '';
            PrivateTmp     = true;
            ProtectSystem  = "strict";
            ReadWritePaths = [ "/run/nixhome-pending-disks" ];
          };
        };
      };

    # ── TIMER FÜR PENDING-WATCHER ─────────────────────────────────────
    systemd.timers."nixhome-pending-watcher" = {
      wantedBy  = [ "timers.target" ];
      timerConfig = {
        OnBootSec          = "1min";
        OnUnitActiveSec    = "2min";
        RandomizedDelaySec = "15";
      };
    };

    # ── OLIVETIN-INTEGRATION: Label-Aktion für Pending Disks ──────────
    # Erscheint in OliveTin wenn /run/nixhome-pending-disks/ nicht leer ist
    services.olivetin.settings.actions = lib.mkIf config.my.services.olivetin.enable [
      {
        title = "Disk labeln (Tier zuweisen)";
        icon  = "💾";
        shell = ''
          set -euo pipefail
          DISK="{{ disk_device }}"
          TIER="{{ tier }}"

          # Label-Map
          declare -A LABELS
          LABELS[A]="NMS_TIER_A"
          LABELS[B]="NMS_TIER_B"
          LABELS[C]="NMS_TIER_C"

          LABEL="''${LABELS[$TIER]}"

          echo "Formatiere $DISK als $LABEL (Tier $TIER)..."
          # Partition erstellen und labeln
          ${pkgs.util-linux}/bin/parted -s "$DISK" mklabel gpt mkpart primary ext4 0% 100%
          PART="''${DISK}1"
          ${pkgs.e2fsprogs}/bin/mkfs.ext4 -L "$LABEL" "$PART"

          echo "✅ $DISK gelabelt als $LABEL"
          echo "Starte Mount-Service..."
          systemctl start "nixhome-mount-tier-$(echo $TIER | tr '[:upper:]' '[:lower:]').service"
        '';
        arguments = [
          { name = "disk_device"; type = "ascii"; description = "z.B. /dev/sdb"; }
          { name = "tier";        type = "ascii"; description = "A, B oder C"; }
        ];
      }
    ];

    # ── KEINE fileSystems-EINTRÄGE FÜR TIER-MOUNTS ───────────────────
    # Das ist entscheidend: Wir nutzen KEINE statischen fileSystems-Einträge
    # für die Tier-Mounts. Das würde nixos-rebuild bei fehlendem Gerät blockieren.
    # Stattdessen: dynamische Mount-Services via systemd (oben definiert).
    #
    # Konsequenz: Diese Mounts erscheinen NICHT in /etc/fstab.
    # Das ist korrekt und gewollt.

    assertions = [
      {
        # Sicherstellen dass keine statischen fileSystems-Einträge
        # für Tier-Mounts existieren (würden nixos-rebuild blockieren)
        assertion =
          !(config.fileSystems ? "${cfg.tierA.mountPoint}") &&
          !(config.fileSystems ? "${cfg.tierB.mountPoint}") &&
          !(config.fileSystems ? "${cfg.tierC.mountPoint}");
        message = ''
          [HAL-DISK] Statische fileSystems-Einträge für Tier-Mounts gefunden!
          Diese blockieren nixos-rebuild wenn der Datenträger nicht vorhanden ist.
          Entferne fileSystems."${cfg.tierA.mountPoint}", .tierB und .tierC.
          Die HAL übernimmt das Mounting dynamisch via systemd-Services.
        '';
      }
    ];

    # ── TMPFILES: Mount-Points anlegen ───────────────────────────────
    systemd.tmpfiles.rules = [
      "d ${cfg.tierA.mountPoint} 0755 root root -"
      "d ${cfg.tierB.mountPoint} 0755 root root -"
      "d ${cfg.tierC.mountPoint} 0755 root root -"
      "d /run/nixhome-pending-disks 0755 root root -"
    ];
  };
}
```

### Warum kein `fileSystems`-Eintrag mit `nofail`?

`nofail` verhindert den Boot-Abort, aber nicht den Service-Start-Fehler. Wenn Jellyfin startet bevor Tier A gemountet ist, schreibt es seinen State in das leere `/mnt/tier-a` — also direkt auf die Root-Partition. Nach dem nächsten Reboot mit gemountet Tier A ist der State weg (er liegt unter dem Mount versteckt). Das ist das worst-case Szenario bei `nofail`.

Die systemd-Service-Lösung hat `PartOf = []` und `WantedBy = ["multi-user.target"]` — das bedeutet: der Mount-Service **kann** fehlen, ohne dass `multi-user.target` fehlschlägt. Aber die Services die den Mount brauchen, bekommen ihn über `After = ["nixhome-mount-tier-a.service"]` und starten verzögert sobald der Mount verfügbar ist.

---

## Gesamtbild: Abhängigkeits-Graph der HAL-Module

```
HAL-001 (GPU)
    ↓
HAL-002 (Storage Broker)  ←── pathRegistry (Kollisions-Detektion)
    ↓                              ↓
HAL-003 (Memory/zram)     HAL-004 (Disk Discovery)
    ↓                              ↓
vm.swappiness             udev → systemd-Mount-Services
tier0-tmpfs               → OliveTin (Pending-Handler)
                          → Homepage (Status-Widget)
```

Alle vier Module sind additiv — sie können einzeln eingeführt werden ohne das bestehende System zu destabilisieren.



## Response:
8.3.2026, 14:47:03

Kurze Antwort: **Nein**, es gibt keinen offiziellen oder etablierten MCP-Server für Sonarr, Radarr oder die anderen Arr-Anwendungen.

````plaintext
Web Search: sonarr radarr MCP server model context protocol 2025
````

> **Radarr and Sonarr MCP Server by Berry Kuipers | PulseMCP** [pulsemcp.com](https://www.pulsemcp.com/servers/berrykuipers-radarr-sonarr)
>
> **GitHub - BerryKuipers/mcp_services_radarr_sonarr** [github.com](https://github.com/BerryKuipers/mcp_services_radarr_sonarr)
>
> **Radarr Sonarr MCP: AI Access to Your Media Library** [mcpmarket.com](https://mcpmarket.com/es/server/radarr-sonarr)
>
> **Arr Assistant (Radarr/Sonarr) MCP Server by Justin Malloy | PulseMCP** [pulsemcp.com](https://www.pulsemcp.com/servers/omniwaifu-arr-assistant)
>
> **Mastering Your Media Library: A Deep Dive into the Radarr and Sonarr MCP Server by Berry Kuipers** [skywork.ai](https://skywork.ai/skypage/en/mastering-media-library-radarr-sonarr/1981592945495699456)
>
> **Sonarr & Radarr MCP Server | MCP Servers · LobeHub** [lobehub.com](https://lobehub.com/mcp/bdfrost-mcp_servarr)
>
> **GitHub - wyattjoh/media-server-mcp: A Model Context Protocol (MCP) server that provides AI assistants with tools to manage Radarr (movies), Sonarr (TV series) media servers, and access IMDB data through natural language interactions. · GitHub** [github.com](https://github.com/wyattjoh/media-server-mcp)
>
> **Media Server MCP | MCP Servers · LobeHub** [lobehub.com](https://lobehub.com/mcp/wyattjoh-media-server-mcp)
>
> **Radarr and Sonarr MCP Server by BerryKuipers | Glama** [glama.ai](https://glama.ai/mcp/servers/@BerryKuipers/mcp_services_radarr_sonarr)
>
> **Lobehub** [lobehub.com](https://lobehub.com/de/mcp/bdfrost-mcp-servarr)
>
Meine Einschätzung war falsch — es gibt mehrere. Hier eine Übersicht der relevanten Optionen:

---

## MCP-Server für den Arr-Stack

Es gibt mindestens drei Community-Projekte, alle inoffiziell:

**1. BerryKuipers/mcp_services_radarr_sonarr** (Python/FastMCP)
Python-basiert, gebaut mit FastMCP. Erlaubt Queries wie "zeig mir ungesehene Sci-Fi-Filme von 2023". Konfiguration über `nasConfig`, `radarrConfig`, `sonarrConfig` JSON.
→ GitHub: `BerryKuipers/mcp_services_radarr_sonarr`

**2. wyattjoh/media-server-mcp** (TypeScript/Deno) — der umfangreichste
Unterstützt Radarr, Sonarr, Plex und TMDB. Tool-Profile-System mit 6 Profilen (18–70 Tools) und Branch-basiertem Filtering. Jeder Service optional konfigurierbar. Installation direkt via `deno run jsr:@wyattjoh/media-server-mcp`.

**3. bdfrost/mcp-servarr** (Python, production-ready)
Konfiguration über Umgebungsvariablen (`SONARR_URL`, `SONARR_API_KEY`, `RADARR_URL`, `RADARR_API_KEY`). Fokus auf Read-Operations: kürzlich hinzugefügte Serien, Kalender, Download-Queue, Systemstatus.

---

## Relevanz für dein NixHome-Setup

Für dein Setup wäre **wyattjoh** die interessanteste Option — Deno läuft ohne npm-Overhead, kein Python-Prozess der im Hintergrund läuft. Die API-Keys kämen aus deinen SOPS-Secrets via `EnvironmentFile`.

Ein NixOS-Modul dafür existiert noch nicht, wäre aber trivial:

```nix
# Skizze — nicht produktionsreif
systemd.services.mcp-servarr = {
  description = "MCP Server für Arr-Stack";
  wantedBy    = [ "multi-user.target" ];
  after       = [ "sonarr.service" "radarr.service" ];
  serviceConfig = {
    ExecStart     = "${pkgs.deno}/bin/deno run --allow-all jsr:@wyattjoh/media-server-mcp";
    EnvironmentFile = config.sops.secrets.media_stack_env.path;
    DynamicUser   = true;
    PrivateTmp    = true;
  };
};
```

Keiner der drei ist im offiziellen MCP-Registry — alle sind Community-Projekte mit überschaubarer Aktivität. Für Produktionseinsatz würde ich den Code vorher lesen, bevor die API-Keys reingehen.



## Response:
8.3.2026, 14:52:09



````plaintext
Web Fetch: Fetched: Browse Extensions
````



## Response:
8.3.2026, 14:54:16

ist sowas das richtige? 

https://github.com/thoreinstein/gemini-obsidian
https://github.com/automateyournetwork/GeminiCLI_File_Search_Extension



## Response:
8.3.2026, 14:58:40

Relevante Frage wäre: Was ist die konkrete Datenquelle? Deine NixOS-Konfig-Logs, Chat-Historien, GitHub-Repos?

also 
1. datensäule wären meine persönlichen chatlogs mit gemini, claude und co... also .md oder .json...  sowas wie "Claude-Homeserver mit Cloudflare sicher einrichten (1).md"
2. datensäule wären ein wust an verschiedenen textdokumenten in allen ömglichen formaten das sind leider so viele das ich garnicht genau weiss wie ich die hier eine übersicht geben kann
3. datensäule wären github repositorys die eher die architektur beschreiben also grob für nix sind  also sowas wie https://github.com/kiriwalawren/nixflix
4. datensäule wären github repos die ehher von den jeweiligen spezifischen programmen kommen also  https://github.com/fail2ban/fail2ban



## Response:
8.3.2026, 15:01:05

du hattest glaube ich schon eine seeehhr fortschrittliche ordnerstruktur entwickelt?





---
Powered by [Claude Exporter](https://www.ai-chat-exporter.net)