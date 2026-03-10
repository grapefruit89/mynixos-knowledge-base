---
title: "Specification: secrets.sops.yaml Template"
category: "services"
tags: [security, sops, secrets, encryption]
date: 2026-03-08
source: "architect-vision-v5"
status: "verified-substance"
---

# 🔐 SERVICE-SPEZIFIKATION: SOPS SECRET TEMPLATE

Jede Instanz der Distribution benötigt eine standardisierte `secrets.sops.yaml`.

## 📋 TEMPLATE-STRUKTUR
```yaml
# ═══════════════════════════════════════════════════
# CLOUDFLARE (DNS-01 & Tunnels)
# ═══════════════════════════════════════════════════
cloudflare:
    api_token: "ENC[AES256_GCM,...]"
    zone_id: "ENC[...]"

# ═══════════════════════════════════════════════════
# VPN & MESH
# ═══════════════════════════════════════════════════
tailscale:
    auth_key: "ENC[...]"

# ═══════════════════════════════════════════════════
# SERVICES
# ═══════════════════════════════════════════════════
n8n:
    encryption_key: "ENC[...]" # Nie mehr im Klartext im Repo!

pocket_id:
    client_secret: "ENC[...]"
```

## 🛡️ SICHERHEITS-PROZESS
1. Nutzer generiert einen Age-Key: `age-keygen -o key.txt`.
2. Nutzer trägt seinen Public-Key in die `.sops.yaml` ein.
3. Nutzer editiert das Template: `sops secrets.sops.yaml`.

> [LIVE-ENRICHMENT]: Die Nutzung von **sops-nix** erlaubt es, diese Secrets direkt in die systemd-Services zu streamen (`EnvironmentFile`), ohne dass die Keys jemals den RAM des laufenden Systems verlassen.
