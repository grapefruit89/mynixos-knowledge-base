---
id: ADR-004
title: Aviation-Grade Security Assertions and Hardening
status: accepted
date: 2026-03-10
tags: [security, nixos-assertions, hardening, nftables, ssh]
---

# ADR-004: Aviation-Grade Security Assertions

## 1. USER LAYER (KISS)
In einer "Aviation-Grade" Umgebung (Sicherheitsstandard Luftfahrt) darf ein System nicht starten, wenn kritische Sicherheitseinstellungen fehlen. Wir nutzen NixOS **Assertions**, um das System beim Booten oder Erstellen (Build-Time) zu prüfen. Wenn z.B. die Firewall versehentlich deaktiviert wurde, bricht der Build sofort ab. Für Tests gibt es einen globalen "Bastelmodus", der diese strengen Regeln temporär lockert.

## 2. TECHNICAL LAYER (Specification)

### Zentrale Mechanismen
Die Assertions sind in `90-policy/security-assertions.nix` definiert und werden global angewendet, außer wenn `config.my.configs.bastelmodus` aktiv ist.

#### Beispiel-Assertions (Nix-Code):
```nix
config.assertions = lib.optionals (!bastelmodus) [
  { 
    assertion = config.networking.firewall.enable == true; 
    message = "[SEC-NET-001] Firewall muss aktiv sein!"; 
  }
  { 
    assertion = config.networking.nftables.enable == true; 
    message = "[SEC-NET-002] Legacy iptables ist untersagt. NFTables nutzen."; 
  }
  { 
    assertion = config.services.openssh.settings.PermitRootLogin == "no"; 
    message = "[SEC-SSH-002] Root-Login über SSH ist in Produktion verboten."; 
  }
];
```

### Die NMS v4.0 Metadaten
Jedes Modul enthält einen `nms` Block (NixHOME Metadata Standard), der Metadaten wie ID, Title, Layer und Audit-Datum liefert. Dies ermöglicht automatisiertes Auditing (`audit.last_reviewed`) und Komplexitätsanalysen.

## 3. REASONING LAYER (ADR)

### Warum Assertions statt nur Default-Werte?
- **Explizite Sicherheit:** Standardwerte in NixOS können durch andere Module (vielleicht aus der Community) überschrieben werden. Assertions garantieren, dass der Endzustand sicher ist.
- **Fehlerprävention:** Menschliche Fehler bei der Refaktorierung werden sofort abgefangen.

### Warum nftables über iptables?
Gemäß dem **No-Legacy-Mandat** (ADR-002) setzen wir auf den modernen Linux-Netzwerk-Stack. Nftables ist performanter und sauberer strukturiert.

### Alternativen (Verworfen):
- **Runtime Auditing (Fail2Ban/Lynis):** Gut, aber nur reaktiv. Assertions sind präventiv (Build-Time).
- **Hard-Coding:** Alle Einstellungen fest in ein Profil schreiben – verhindert Flexibilität bei Multi-Host Setups.

---
> [ARCHITECT-NOTE]: Extrahiert aus mynixos/90-policy/security-assertions.nix (v2026.03.02)
