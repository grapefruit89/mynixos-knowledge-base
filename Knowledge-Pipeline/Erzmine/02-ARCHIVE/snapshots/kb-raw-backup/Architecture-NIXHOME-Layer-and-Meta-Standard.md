# Architecture: NIXHOME Layer-Structure & Meta-Standard

## 1. User Layer (KISS)
Dieses Dokument definiert, wie wir Ordnung in deine über 90 Nix-Konfigurationsdateien bringen. Jede Datei hat einen festen Platz in einem von sieben Schichten (Layern) und trägt einen "Ausweis" (Meta-Header) am Anfang. Dieser Header verrät uns (und der KI) sofort, was das Modul tut, welche Ports es nutzt und wovon es abhängig ist. So bleibt dein System auch bei massivem Wachstum übersichtlich und durchsuchbar.

## 2. Technical Layer (Aviation-Grade)

### Die 7-Layer Architektur
Jedes Modul wird anhand einer Kernfrage einem Layer zugeordnet:
*   **00-core:** Ohne dies ist das OS unsicher oder startet nicht. (SSH, Firewall, Boot).
*   **20-server:** Ohne dies ist der Server nicht erreichbar. (Caddy, Tailscale, DNS, DBs).
*   **30-services:** Dienste, die du täglich nutzt. (Vaultwarden, Home Assistant, n8n).
*   **40-media:** Alles rund um Audio/Video. (Jellyfin, ARR-Stack).
*   **50-knowledge:** Persönliches Wissen & Dokumente. (Paperless, Monica, RSS).
*   **80-monitoring:** Passive Beobachtung des Systems. (Netdata, Uptime Kuma).
*   **90-policy:** Regeln und Enforcement. (Assertions, Struktur-Checks).

### Der NMS-Meta-Header Standard (v4.2 Aviation-Grade)
Im Gegensatz zu passiven Kommentaren nutzen wir in v4.2 **aktive, aber passive Nix-Attribute**. Dies erlaubt dem System, seine eigenen Metadaten zur Laufzeit zu validieren (z.B. in der REPL), ohne den `nixos-rebuild` zu belasten.

#### Performance-Mandat (Zero-Build-Cost):
Ein Metadaten-Block darf **NIEMALS** rechenintensive Funktionen wie `builtins.hashFile`, `lib.readFile` oder andere Dateisystemzugriffe enthalten. Er muss ein **reines, statisches Attribut-Set** sein. Jeder Integritätscheck (Checksummen) ist ein separater CI-Schritt und darf nicht Teil der Nix-Evaluation während des System-Builds sein.

#### Schema (Auszug aus `00-core/storage.nix`):
```nix
let
  nms = {
    id = "NIXH-20-INF-005";
    title = "Storage Pool Management";
    description = "MergerFS SSD/HDD Tiering Logic.";
    layer = 20;
    nixpkgs.category = "system/storage";
    capabilities = [ "storage/mergerfs" "performance/tiering" ];
    audit.last_reviewed = "2026-03-10";
    audit.complexity = 3; # 1-5 (SRE Metric)
  };
in
{
  options.my.meta.storage = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };
}
```

#### Schlüssel-Erweiterungen in v4.2:
*   **`capabilities`:** Eine Liste von standardisierten Tags (z.B. `gpu/intel-qsv`), die es automatisierten Skripten erlaubt, Hardware-Anforderungen oder Software-Features systemweit zu mappen.
*   **`audit.complexity`:** Ein SRE-Indikator für die Wartbarkeit (1 = trivial, 5 = hochgradig komplex/fragil).
*   **`nixpkgs.category`:** Verlinkung zur offiziellen Nixpkgs-Hierarchie für bessere Auffindbarkeit.

### Modul-Prioritäten & SSoT (Aviation-Grade)
1.  **configs.nix (00-core):** Master-Konfiguration (Hardware-IDs, IPs, SSoT-Schalter).
2.  **ports.nix (00-core):** Zentrales Port-Register (Zuweisung via `config.my.ports.X`).
3.  **defaults.nix (00-core):** Globale Hardening-Standards (Fail2Ban, Sysctl, DNS).

## 3. Reasoning Layer (History)

### [ADR-010] Übergang zu Active Metadata (v4.2)
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Passive Kommentar-Header (v2.3) können veralten und sind nicht maschinenlesbar innerhalb von Nix.
*   **Entscheidung:** Metadaten werden als Read-Only Optionen (`options.my.meta.*`) direkt in den Modul-Code integriert.
*   **Vorteile:** Vollständige Traceability innerhalb der Nix-REPL, automatisierte Generierung von Compliance-Reports und direkte Verknüpfung mit dem Monitoring (z.B. Netdata-Labels basierend auf Meta-Capabilities).

### [ADR-011] Transparente flake.nix (Option B)
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Import-Hubs (`_imports.nix`) verstecken die tatsächliche Struktur des Systems vor der `flake.nix`.
*   **Entscheidung:** Wir listen alle Module explizit in der `flake.nix` auf.
*   **Vorteil:** Maximale Transparenz. Man sieht beim ersten Blick in die `flake.nix`, welche Dienste aktiv sind und in welcher Reihenfolge sie geladen werden.

---
**Sources:**
*   `/home/Knowledge-Pipeline/raw/_duplikate/NIXHOME_META_AND_FLAKES.md`
*   `/home/Knowledge-Pipeline/raw/_duplikate/NIXHOME_ARCHITECTURE.md`
*   `/home/Knowledge-Pipeline/raw/_duplikate/geminiverbesserung.txt`
