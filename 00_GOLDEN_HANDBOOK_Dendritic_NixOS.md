---
title: Das Goldene Handbuch (Dendritic NixOS Master-Edition)
category: architecture/master-guide
capabilities: [dendritic-pattern, sre-standard, aviation-grade-purity]
sources: [https://github.com/mightyiam/dendritic, https://github.com/hercules-ci/flake-parts, https://github.com/Mic92/sops-nix]
---

# 👑 Das Goldene Handbuch: Dendritic NixOS (State-of-the-Art)

Dieses Handbuch ist die Single Source of Truth (SSoT) für den Aufbau einer modernen, modularen und unzerstörbaren NixOS-Distribution.

## 📖 Inhaltsverzeichnis

1.  [**Die Dendritische Philosophie**](./GUIDE-Dendritic-Modularization.md) - Warum Modularisierung gewinnt.
2.  [**Die 7 Qualitäts-Tore**](./GUIDE-Seven-Quality-Gates.md) - Der Aviation-Grade Prüfstandard.
3.  [**Hardening & Secrets**](./GUIDE-SRE-Hardening-Secrets.md) - sops-nix und age in der Praxis.
4.  [**Hygiene & Persistence**](./Strategy-Impermanence-Tiered-Storage.md) - Impermanence für flüchtige Systeme.
5.  [**Container-Symbiose**](./arion.md) - Arion: Die Brücke zu Docker.

## 🛡️ Das Fundament: Layer-Architektur
Wir folgen der strikten Trennung von Belangen (Separation of Concerns):
- **Layer 10 (User):** Home-Manager & Dotfiles.
- **Layer 40 (Security):** Sops-nix & SSH-Keys.
- **Layer 60 (Services):** Arion & NixOS-Module.
- **Layer 80 (Hardware):** Disko & Hardware-Profile.

---
> [!IMPORTANT]
> Jede Änderung am System MUSS zuerst die 7 Qualitäts-Tore passieren, bevor sie in das mynixos-Repository einfließt.
