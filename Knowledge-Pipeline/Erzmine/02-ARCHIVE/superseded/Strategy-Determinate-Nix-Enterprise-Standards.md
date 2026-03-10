---
title: "Strategy: Determinate Nix Enterprise Standards (Aviation-Grade)"
category: "learnings"
tags: [nix, performance, security, enterprise, determinate-systems]
id: "NIXH-STRAT-004"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["https://determinate.systems/determinate-nix/"]
---

# Strategy: Determinate Nix Enterprise Standards

## 1. User Layer (KISS)
Dieses Dokument definiert den Unterbau deines Servers. Wir nutzen nicht das "normale" Nix, sondern eine spezialisierte, professionelle Version namens **Determinate Nix**. Sie ist schneller, sicherer und nimmt dir mühsame Wartungsarbeit (wie das Aufräumen der Festplatte) ab. Damit stellen wir sicher, dass dein Homelab auf dem gleichen technischen Niveau wie moderne IT-Abteilungen läuft.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Distribution
*   **Security-Validierung:** Jeder Release ist SOC 2 Type II validiert und verfügt über einen definierten CVE-Prozess (Sicherheitslücken-Management).
*   **Determinate Nixd:** Ein Hintergrund-Dienst, der Installationen, Upgrades und die Garbage Collection automatisiert.

### Performance-Konfiguration
Um die Hardware deines Fujitsu Q958 optimal zu nutzen, erzwingen wir folgende Parameter in der `nix.custom.conf`:
*   **Parallel Evaluation:** `eval-cores = 0` (Nutzung aller 4 Kerne des i3-9100). Reduziert die Evaluierungszeit um ca. 50%.
*   **Lazy Trees:** Standardmäßig aktiv. Scoped das Kopieren von Dateien auf das absolute Minimum. Reduziert Disk-Usage im Nix-Store massiv (Faktor 20x bei großen Repos).

### Managed Maintenance
*   **GC-Strategie:** Automatisches Freihalten von mindestens 30GB Disk-Space.
*   **Urgent Mode:** Automatisches Auslösen der Garbage Collection, falls der freie Speicher unter 5% fällt.

### Integration (Nix-Snippet)
```nix
# Deklarative Konfiguration von Determinate Nixd
environment.etc."determinate/config.json".text = builtins.toJSON {
  garbageCollector.strategy = "automatic";
  builder.state = "enabled";
};
```

## 3. Reasoning Layer (History)

### [ADR-075] Determinate Nix vs. Upstream Nix
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Upstream Nix ist oft sehr experimentell und erfordert viele manuelle Entscheidungen bei der Optimierung.
*   **Entscheidung:** Migration zur Determinate Nix Distribution.
*   **Vorteil:** "Fewer decisions, more confidence." Die Distribution liefert bereits die besten Standardwerte für Performance und Sicherheit. Der professionelle Support-Hintergrund erhöht die Langlebigkeit der Architektur.

---
**Community-Abgleich:** Vollständig konform zum aktuellen Industriestandard für Nix-Infrastrukturen.
