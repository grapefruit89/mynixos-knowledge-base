---
title: 📦 S3 Object Vault (Garage HQ)
category: architecture/storage
status: [ACTIVE-SSoT]
capabilities: [s3-compatible, distributed-storage, rust-efficiency, tiered-metadata]
sources: [https://github.com/deuxfleurs/garage, official nixpkgs modules]
---

# 📦 Garage: Dein privates S3-Rechenzentrum

In mynixos ist Garage der Standard für objektbasierten Speicher. Er ist die ideale Ergänzung zu ZFS/MergerFS für Anwendungen, die eine S3-API benötigen.

## 🏛️ Architektur-Entscheidungen (Tiered Mastery)
1.  **Metadata Layer:** Liegt zwingend auf Tier A (NVMe ZFS Mirror). ✅
2.  **Data Layer:** Liegt auf Tier C (HDD SnapRAID/MergerFS). ✅
3.  **Sprache:** Rust (Efficiency Mandate erfüllt). ✅

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/20-server/storage-s3.nix\`):

\`\`\`nix
services.garage = {
  enable = true;
  settings = {
    metadata_dir = "/persist/var/lib/garage/meta"; # Tier A
    data_dir = "/mnt/storage/garage/data";        # Tier C
    rpc_bind_addr = "[::]:3901";
    s3_api = {
      s3_region = "mynixos-local";
      api_bind_addr = "[::]:3900";
    };
  };
};
\`\`\`

## 🛡️ SRE-Hardening
- **Access Control:** Wir nutzen \`garage key create\` für dedizierte S3-Keys pro Dienst (z.B. für Restic-Backups von anderen Geräten).
- **Ingress:** Sicherung der S3-API via Caddy über \`s3.m7c5.de\` mit mTLS für externe Zugriffe.