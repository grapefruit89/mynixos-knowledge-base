---
title: ☁️ ownCloud Infinite Scale (OCIS) Master-Config
category: architecture/services
status: [ACTIVE-SSoT]
capabilities: [cloud-storage, go-performance, oidc-ready, database-less]
sources: [https://github.com/owncloud/ocis, NixOS Manual]
---

# ☁️ ownCloud OCIS: Deine Cloud in Go

In mynixos setzen wir auf ownCloud Infinite Scale (OCIS) als modernen Cloud-Speicher (Layer 50-knowledge).

## 🏛️ Architektur-Entscheidungen (Efficiency Standard)
1.  **Sprache:** Go (Binary-Mandat erfüllt).
2.  **Datenbank-los:** OCIS nutzt ein Metadaten-System auf dem Dateisystem. Keine MySQL/PostgreSQL für die Cloud-Struktur nötig (RAM-Ersparnis).
3.  **Identity:** Nativer OIDC-Support (perfekt für PocketID).

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/50-knowledge/cloud.nix\`):

\`\`\`nix
services.ocis = {
  enable = true;
  url = \"https://cloud.m7c5.de\";
  port = 9200;
  address = \"127.0.0.1\";
  environment = {
    OCIS_LOG_LEVEL = \"info\";
    # Weitere Variablen für Storage-Backends
  };
  # Secrets via Sops
  environmentFile = config.sops.secrets.\"ocis/env\".path;
};
\`\`\`

## 🛡️ SRE-Hardening
- **Isolation:** OCIS läuft als dedizierter User und nutzt systemd-Härtung.
- **Ingress:** Caddy (Layer 20) übernimmt das TLS-Termination und mTLS-Sicherung.
- **Storage-Mapping:** Die Cloud-Daten liegen in \`/persist/var/lib/ocis\` (Impermanence Standard).
"""

write_file('/home/Knowledge-Pipeline/docs/guides/GUIDE-Cloud-Storage-OCIS.md', content)
