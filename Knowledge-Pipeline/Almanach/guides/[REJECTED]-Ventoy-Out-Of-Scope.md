# [GUIDE]: Multiboot Sovereignty mit Ventoy
# ID: [NUGGET-BOOT-001] | Status: ACTIVE | Stand: 10.03.2026

## 1. Vision & Zweck
Ein "Aviation-Grade" Administrator braucht ein mobiles Rettungssystem. Ventoy ist der Standard, um mehrere ISOs (NixOS, Memtest, Clonezilla) auf einem einzigen Stick zu verwalten, ohne den Stick jedes Mal neu zu flashen.

## 2. Die NixOS-Integration
Um NixOS optimal auf Ventoy zu nutzen, müssen wir sicherstellen, dass die ISO-Labels eindeutig sind.

### Strategie: Custom ISO Build
Wir bauen unser eigenes Rettungs-ISO via Nix:
```nix
{ pkgs, ... }: {
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix> ];
  networking.hostName = "rescue-stick";
  environment.systemPackages = with pkgs; [ git vim sops age ];
}
```

## 3. Ventoy "Persistence" Trick
Normalerweise sind ISOs read-only. Für NixOS nutzen wir einen separaten Partition-Label `NIX_RESCUE_DATA`, den wir beim Booten via `fileSystems` mounten, um Configs und Secrets auch vom Stick aus griffbereit zu haben.

---
> [SOURCE]: /root/mynixos_full_goldmine.md
