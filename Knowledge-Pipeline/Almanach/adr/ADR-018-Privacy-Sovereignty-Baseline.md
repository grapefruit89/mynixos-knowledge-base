# [ADR-018]: Privacy & Sovereignty Baseline (2026)
# ID: [NUGGET-PRIV-001] | Status: ACCEPTED | Stand: 10.03.2026

## 1. Context (User Layer)
Daten-Souveränität bedeutet nicht nur, Daten lokal zu speichern, sondern jeden Angriffsvektor (Netzwerk-Sniffing, physischer Diebstahl, ungesicherte APIs) zu eliminieren. Privacy Guides Standards verlangen ein "Zero-Trust" Mindset.

## 2. Decision (Technical Layer)
Wir etablieren die folgenden vier Säulen der Souveränität:

1. **Verschlüsselter Ingress (Caddy):**
   - Ausschließlich HTTP/3 und TLS 1.3 (Secure by Default).
   - Strikte Security-Headers (`HSTS`, `nosniff`, `CSP`).
2. **Zero-Trust Access (Tailscale/Cloudflare):**
   - Keine offenen Ports (außer 80/443 für Caddy, falls public).
   - Interner Traffic läuft komplett über das WireGuard-Mesh (Tailscale).
3. **DNS Privacy (AdGuard / Unbound):**
   - Plaintext DNS (Port 53) ins Internet ist verboten.
   - Upstream-Queries nutzen DNS-over-QUIC (DoQ) oder Oblivious DoH (ODoH).
4. **Encryption at Rest (ZFS):**
   - Physischer Diebstahl der Q958-Platten darf keine Daten offenbaren.
   - Wir nutzen "ZFS Native Encryption" für inkrementelle, verschlüsselte Offsite-Backups (Raw Send/Receive).

### 2.1 Umsetzung in der Werkstatt (Zukunft)
```nix
# Caddy Hardening Beispiel
services.caddy.globalConfig = 
  servers {
    protocols h1 h2 h3
    strict_sni_host on
  }
;
```

## 3. Reasoning (Reasoning Layer)
- **Warum ZFS statt LUKS?** LUKS verschlüsselt die ganze Disk, ZFS-Native verschlüsselt Datasets. Das erlaubt es, verschlüsselte Backups (via zfs send) an untrusted Cloud-Provider (wie rsync.net) zu senden, ohne den Entschlüsselungs-Key mitzugeben.
- **Warum DoQ/ODoH?** Es schützt Metadaten vor dem ISP.
