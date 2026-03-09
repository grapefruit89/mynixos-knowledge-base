# 👑 MASTER-SOURCES: Die Aviation-Grade Goldkammer (Server-Only)
Diese Datei ist die ultimative Single Source of Truth für alle Architektur-Links und Repositories deines Systems.

## 🏛️ NixOS Official (The Core)
- [nixpkgs](https://github.com/NixOS/nixpkgs) - The heart of the ecosystem.
- [nix.dev](https://github.com/NixOS/nix.dev) - Official guide for "Getting Things Done" (Aviation-Grade Docs).
- [infra](https://github.com/NixOS/infra) - Reference server configurations for nixos.org.
- [nixops](https://github.com/NixOS/nixops) - Professional network deployment tool.
- [nixos-hardware](https://github.com/NixOS/nixos-hardware) - Server-optimized hardware profiles.
- [ofborg](https://github.com/NixOS/ofborg) - Automation and CI infrastructure.
- [nix-security-tracker](https://github.com/NixOS/nix-security-tracker) - Vulnerability management.

## 🌳 hercules-ci (Automation & Structure)
- [flake-parts](https://github.com/hercules-ci/flake-parts) - The framework for your Dendritic architecture.
- [arion](https://github.com/hercules-ci/arion) - The bridge between Nix and Docker-Compose.
- [hercules-ci-agent](https://github.com/hercules-ci/hercules-ci-agent) - The engine for remote builds.
- [effects](https://github.com/hercules-ci/effects) - Declarative side-effects and deployment.

## 🛡️ nix-community (SRE-Hardening)
- [disko](https://github.com/nix-community/disko) - Declarative disk partitioning (ZFS/LUKS).
- [impermanence](https://github.com/nix-community/impermanence) - Ephemeral root strategy (M1 Abrams Hygiene).
- [home-manager](https://github.com/nix-community/home-manager) - Reproducible user environments.
- [sops-nix](https://github.com/Mic92/sops-nix) - Atomic secrets management (via Mic92).
- [nix-index](https://github.com/nix-community/nix-index) - Global file search for nixpkgs.

## 🧩 mightyiam & Victor Borja (Dendritic Masters)
- [dendritic](https://github.com/mightyiam/dendritic) - The original pattern blueprint.
- [infra](https://github.com/mightyiam/infra) - Reference for modular IT infrastructure.
- [import-tree](https://github.com/vic/import-tree) - Automatic nix file discovery (Critical Engine).
- [den](https://github.com/vic/den) - Aspect-oriented, context-driven configurations.
- [denful](https://github.com/vic/denful) - Reusable, cherry-pickable Dendritic modules.
- [checkmate](https://github.com/vic/checkmate) - Flake checker using nix-unit and treefmt.

## 🔐 Identity & Security (Ingress & Auth)
- [pocket-id](https://github.com/pocket-id/pocket-id) - OIDC provider with Passkey authentication.
- [jailed-agents](https://github.com/andersonjoseph/jailed-agents) - Secure Nix sandboxing using bubblewrap.
- [caddy](https://github.com/caddyserver/caddy) - Fast web server with automatic HTTPS.
- [certmagic](https://github.com/caddyserver/certmagic) - Powerhouse behind Caddy's TLS.

## 🏢 Determinate Systems (Enterprise Nix)
- [nix-installer](https://github.com/DeterminateSystems/nix-installer) - The modern Nix installer.
- [flake-checker](https://github.com/DeterminateSystems/flake-checker) - Automated health checks for flakes.
- [magic-nix-cache](https://github.com/DeterminateSystems/magic-nix-cache) - Zero-config binary cache for CI.

## 🔍 SRE Audit & Visualization
- [NixoScope](https://github.com/giomf/NixoScope) - Dependency visualizer for Dendritic Nix.
