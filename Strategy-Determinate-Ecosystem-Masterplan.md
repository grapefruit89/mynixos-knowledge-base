---
title: "Strategy: Determinate Ecosystem Masterplan (Aviation-Grade)"
category: "learnings"
tags: [nix, architecture, maintenance, automation, determinate-systems]
id: "NIXH-STRAT-007"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["https://docs.determinate.systems/", "https://github.com/DeterminateSystems/"]
---

# Strategy: Determinate Ecosystem Masterplan

## 1. User Layer (KISS)
Dieses Dokument vereint alle Werkzeuge von Determinate Systems zu einem perfekten Gesamtbild. Wir nutzen den intelligenten Installer für den Start, den `fh`-Helfer für die Ordnung deiner Module und den `determinate-nixd` Wächter, damit dein Server niemals wegen einer vollen Festplatte stehen bleibt. Das Ziel ist ein Server, der sich wie ein professionelles Rechenzentrum anfühlt, aber in deinem Schrank steht.

## 2. Technical Layer (Aviation-Grade)

### Modul-Struktur & Initialisierung (via fh CLI)
*   **Standard:** Alle neuen "Dendritischen Module" werden mit `fh init` vorbereitet.
*   **SemVer:** Wir nutzen semantische Versionierung für Flake-Inputs, um kritische Infrastruktur-Updates zu kontrollieren.
*   **Schemas:** Metadaten werden als offizielle Flake-Outputs (`outputs.schemas`) exportiert.

### Managed Maintenance (Determinate Nixd)
*   **Disk-Guard:** Der Daemon garantiert 30GB freien Speicherplatz durch intelligentes Aufräumen.
*   **Health:** `determinate-nixd status` dient als primärer Gesundheitscheck für den Nix-Stack.
*   **Bootstrapping:** Integration von `determinate-nixd init --keep-mounted` in die **Stage-1** deiner Boot-Pipeline.

### Performance-Enforcement
Erzwingung der Aviation-Grade Parameter in `/etc/nix/nix.custom.conf`:
*   `eval-cores = 0` (Volle Parallelisierung).
*   `lazy-trees = true` (Minimale I/O-Last).
*   `builders-use-substitutes = true` (Download-first Policy).

### Integration (Nix-Snippet)
```nix
# Zentrales Maintenance-Modul (Layer 00-core)
{
  services.determinate-nixd.enable = true;
  nix.settings = {
    eval-cores = 0;
    lazy-trees = true;
  };
}
```

## 3. Reasoning Layer (History)

### [ADR-078] Full Adoption of Determinate Toolchain
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Die manuelle Wartung von Nix-Versionen, Caches und Disk-Space erzeugt hohen operativen Aufwand (Toil).
*   **Entscheidung:** Kompletter Wechsel auf die Determinate Systems Toolchain (fh, nix-installer, nixd).
*   **Vorteil:** Konsistenz zwischen Entwicklungs-Laptop und Server. Höchstmögliche Stabilität durch SOC 2 validierte Releases.

### [ADR-079] Custom Config via nix.custom.conf
*   **Begründung:** Wir verändern niemals die vom Installer generierte `nix.conf`, um Upgradepfadsicherheit zu garantieren. Alle unsere Optimierungen landen sauber getrennt in der `nix.custom.conf`.

---
**Community-Abgleich:** Entspricht den "Golden Path" Empfehlungen für moderne Nix-Infrastrukturen.
