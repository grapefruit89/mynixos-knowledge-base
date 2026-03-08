---
title: "Specification: USER_CONFIG.nix"
category: "services"
tags: [nixos, configuration, abstraction, dendritic]
date: 2026-03-08
source: "architect-vision-v5"
status: "verified-substance"
---

# 🛠️ SERVICE-SPEZIFIKATION: USER_CONFIG.NIX

Dieses Dokument definiert das Interface zwischen dem Endnutzer und der `mynixos` Architektur.

## 📋 STRUKTUR-BEISPIEL
Die Konfiguration nutzt `den.options`, um die Komplexität hinter einfachen Flags zu verbergen.

```nix
{
  # --- SYSTEM BASIS ---
  hostname = "tower";
  username = "moritz";
  timezone = "Europe/Berlin";
  domain   = "m7c5.de";

  # --- NETWORKING ---
  tailscale.enable = true;
  adguard.enable   = true;

  # --- MEDIA STACK ---
  jellyfin.enable = true;
  jellyfin.domain = "media.m7c5.de";
  
  radarr.enable = true;
  sonarr.enable = true;

  # --- AUTOMATION ---
  n8n.enable = true;
  vaultwarden.enable = true;
}
```

> [ARCHITECT-NOTE]: Die `USER_CONFIG.nix` sollte niemals Nix-Logik enthalten, sondern lediglich ein Attribut-Set von Optionen sein. Die Validierung erfolgt im Hintergrund über die Layer-Module.

> [LIVE-ENRICHMENT]: Unter NixOS 24.11+ können wir `lib.evalModules` nutzen, um dem Nutzer sofort beim Speichern (LSP/nixd) anzuzeigen, wenn er einen ungültigen Wert oder eine fehlende Pflichtangabe eingetragen hat.
