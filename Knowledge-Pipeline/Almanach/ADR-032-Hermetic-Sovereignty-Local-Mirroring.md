# [ADR-032]: Hermetic Sovereignty (Local Source Mirroring)
# ID: [ADR-032] | Status: ACCEPTED | Stand: 10.03.2026

## 1. User Layer (KISS)
Wir akzeptieren nicht, dass unser Betriebssystem von der Erreichbarkeit externer Server (wie GitHub) abhängt. Ein "Aviation-Grade" System muss auch dann rebuild-fähig sein, wenn das Internet abgeschaltet wird.

## 2. Technical Layer (Spezifikation)
- **Problem:** Standard-Nix-Flakes laden Quellen dynamisch von GitHub. Verschwindet das Repo, bricht der Build.
- **Lösung:** "Local Vendoring". Alle Inputs der `flake.nix` müssen auf lokale Pfade oder unsere interne Forgejo-Instanz (ADR-024) zeigen.
- **Workflow:** 
  1. `git clone --mirror` von nixpkgs in `/mnt/storage/forge/nixpkgs`.
  2. `flake.nix` Input-URL: `git+file:///mnt/storage/forge/nixpkgs?ref=nixos-unstable`.
  3. Regelmäßige, manuelle Synchronisation (Sovereign Update).

## 3. Reasoning Layer (ADR)
- **Warum?** Schutz vor "Source Link Rot" und Zensur. Totale Autarkie für den Katastrophenfall.
- **Vorteil:** Builds sind extrem schnell, da keine Netzwerk-Latenz.
- **Nachteil:** Erhöhter lokaler Speicherbedarf (~5-10 GB für nixpkgs History). Das ist auf dem Q958 vernachlässigbar.

---
> [SOURCE]: Benutzer-Mandat zur Unabhängigkeit von GitHub (10.03.2026)
