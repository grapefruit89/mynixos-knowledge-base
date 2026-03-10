# [PATTERN]: Sovereign Media-Stack (Nixflix Extraction)
# ID: [NUGGET-MEDIA-002] | Status: INTERNALIZED | Stand: 10.03.2026

## 1. Architectural Logic (The Essence)
Die Analyse von `nixflix` hat drei Gold-Nuggets ergeben, die wir in unsere Werkstatt übernehmen:
- **UID/GID Symmetrie:** Feste IDs für Media-User verhindern Rebuild-Inkonsistenzen bei Berechtigungen.
- **PostgreSQL Dependency-Chain:** Die Nutzung eines `postgresql-ready` Targets stellt sicher, dass der Stack erst startet, wenn die DB wirklich bereit ist.
- **Automatisierte API-Verdrahtung:** Radarr/Sonarr werden via Nix-Logik vorkonfiguriert (Ports, API-Versionen), anstatt manuell im UI.

## 2. Native NixOS Code (Transformation)
Hier ist die extrahierte Logik, befreit von Arion/Docker-Altlasten:

### A. Zentralisierte IDs (Werkstatt Integration)
Wir integrieren diese IDs in unsere `globals.nix`, um die "Aviation-Grade" Konsistenz zu wahren.
```nix
{
  # Konsistente UIDs für Media-Stack
  my.uids = {
    jellyfin = 146;
    radarr = 275;
    sonarr = 274;
    prowlarr = 293;
    media = 169; # GID
  };
}
```

### B. PostgreSQL Media-Tuning
```nix
services.postgresql = {
  enable = true;
  package = pkgs.postgresql_16;
  settings = {
    # [NUGGET]: Optimierung für viele kleine ARR-Writes
    shared_buffers = "256MB";
    work_mem = "16MB";
  };
};
```

## 3. Hardening & Sovereignty (ADR-032)
Um den Media-Stack autark zu betreiben und GitHub-Abhängigkeiten zu eliminieren:

### A. Lokale Spiegelung (Forgejo)
1. `git clone --mirror https://github.com/kiriwalawren/nixflix.git /mnt/storage/forge/nixflix.git`
2. **In unserer Flake:**
```nix
inputs.nixflix-logic.url = "git+file:///mnt/storage/forge/nixflix.git";
```

### B. Hermetischer Betrieb
Der gesamte Stack wird durch unsere `OnFailure` ntfy-Integration (ADR-025) überwacht. Wir nutzen keine externen Docker-Registries mehr, sondern bauen die Binaries nativ aus den lokalen `nixpkgs` Spiegeln.

---
> [SOURCE-NUGGET]: Extracted from nixflix-analysis (10.03.2026)
