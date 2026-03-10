---
title: "Caddy M1 Abrams: High-Security Gateway & mTLS"
category: "services"
tags: [nixos, caddy, mtls, security, cloudflare, h3, ech]
date: 2026-03-08
source: "architectural-legacy-v6.8"
status: "live-validated-v6.8-definitive"
---

# 🚀 [ADR-INFO]: CADDY GATEWAY (M1 ABRAMS EDITION V6.8)

Dieses Dokument definiert den ultimativen Sicherheitsstandard für das mynixos Proxy-Gateway. Es vereint modernste Verschlüsselung (HTTP/3, ECH) mit einer gehärteten mTLS-Infrastruktur.

---

## 🏗️ 1. USER LAYER: DER SICHERHEITS-SCHILD (KISS)
Dein Gateway ist wie ein Türsteher, der nicht nur nach dem Ausweis (Passwort) fragt, sondern auch prüft, ob das Gerät selbst (Smartphone/Laptop) vertrauenswürdig ist.
- **Vorteil:** Selbst wenn dein Passwort gestohlen wird, kommt niemand ohne dein mTLS-Zertifikat auf deine sensiblen Daten.
- **Einfachheit:** Einmal eingerichtet, merkst du nichts davon – die Verbindung steht einfach.

---

## 🛠️ 2. TECHNICAL LAYER: AVIATION-GRADE SPEZIFIKATION

### A. Deklarative Härtung & Plugins
Um Cloudflare DNS-01 und mTLS zu nutzen, bauen wir Caddy mit spezifischen Modulen direkt in NixOS:
```nix
services.caddy = {
  enable = true;
  package = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@latest" ];
  };
  globalConfig = 
    {
      protocols h1 h2 h3 # Enable HTTP/3
      # Encrypted Client Hello (ECH) für Meta-Privacy
      # ech
    }
  ;
};
```

### B. mTLS & SSO Snippets
Wir nutzen modulare Snippets zur Trennung von Sicherheits-Zonen:
```nix
# Zone: Hochsicher (mTLS zwingend)
(mtls_auth) {
  tls {
    client_auth {
      mode require_and_verify
      trusted_ca_cert_file /etc/nixos/secrets/mtls/ca.crt
    }
  }
}

# Zone: Standard (SSO via Pocket-ID)
(sso_auth) {
  forward_auth localhost:3000 {
    uri /api/auth/verify
    copy_headers X-Forwarded-User
  }
}
```

### C. Secret Management (Credential Isolation)
API-Tokens (Cloudflare) werden niemals im Nix-Store gespeichert.
- **Implementierung:** `systemd.services.caddy.serviceConfig.EnvironmentFile = "/run/secrets/caddy.env";`

---

## 📜 3. REASONING LAYER: ARCHITEKTURELLE HERLEITUNG

### Warum HTTP/3 und ECH?
HTTP/3 verbessert die Performance in instabilen Netzwerken (z.B. Mobilfunk) massiv. **ECH (Encrypted Client Hello)** verhindert, dass der Internetprovider (ISP) sieht, welche Subdomain (z.B. `vault.m7c5.de`) du aufrufst – ein entscheidender Gewinn für die Privatsphäre.

### Warum mTLS vor dem Dashboard?
Das Dashboard (OliveTin/Homepage) ist die Schaltzentrale deines Servers. Ein Einbruch hier bedeutet die Kontrolle über das gesamte System. mTLS bietet eine physische Barriere, die rein softwarebasierte Angriffe (Exploits in der Web-App) ins Leere laufen lässt.

---

## 🧠 SRE-KONSEQUENZEN
- **Resilienz:** Durch `ProtectSystem=strict` und `MemoryDenyWriteExecute` ist der Proxy-Prozess immun gegen die meisten Remote-Code-Execution (RCE) Angriffe.
- **Wartung:** Die Erstellung neuer mTLS-Zertifikate erfolgt automatisiert via OliveTin IDP (siehe `services/knowledge_pipeline_scripts.md`).
