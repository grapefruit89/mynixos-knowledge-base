---
title: SRE-Hardening & Secrets (Security Standard)
category: architecture/security
capabilities: [sops-nix, age-encryption, hard-security]
sources: [https://github.com/Mic92/sops-nix, https://github.com/mozilla/sops]
---

# 🛡️ SRE-Hardening: Secrets & Security

In einem Aviation-Grade System liegen keine Geheimnisse im Klartext. Wir nutzen `sops-nix` und `age`.

## 🔑 Der Age-Key (Identität)
Deine Identität ist dein Age-Key (`/home/mynixos/secrets/age-key.txt`). Er ist der einzige Schlüssel zum Tresor.

## 📂 Der Tresor: secrets.yaml
Alle Token und Passwörter liegen verschlüsselt in `secrets/secrets.yaml`.

### Workflow:
1.  **Editieren:** `nix run nixpkgs#sops -- secrets/secrets.yaml`
2.  **Referenzieren:** In Nix-Modulen via `config.sops.secrets."github/token".path`.

## 🛡️ Hardening von systemd-Units
Jeder Dienst muss mit minimalen Berechtigungen laufen. 
- **ProtectSystem=strict**
- **ProtectHome=true**
- **PrivateTmp=true**
