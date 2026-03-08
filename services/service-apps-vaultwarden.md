---
title: "Service: Vaultwarden (Aviation-Grade Password Manager)"
category: "services"
tags: [security, passwords, socket-activation, dendritic]
id: "NIXH-60-APP-007"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["60-apps/service-app-vaultwarden.nix"]
---

# Service: Vaultwarden (Secure Vault)

## 1. User Layer (KISS)
Vaultwarden ist dein Tresor für Passwörter. Es schützt deine Zugangsdaten mit modernster Verschlüsselung. Der Dienst schläft, solange er nicht gebraucht wird, und wacht blitzschnell auf, wenn du dein Browser-Plugin nutzt.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Ressourcen
* **Socket-Activation:** Minimiert RAM-Overhead im Leerlauf.
* **Backend:** Hochperformanter Rust-Port von Bitwarden.
* **Secrets:** Konfiguration via verschlüsselter Environment-Datei.

### SRE Hardening
* **Isolation:** MemoryDenyWriteExecute = true und striktes IP-Filtering.
* **Policy:** Öffentliche Registrierung ist deaktiviert.

## 3. Reasoning Layer (History)

### [ADR-066] No SSO for Vault
Vaultwarden wird bewusst nicht an das SSO-System angebunden, um eine Rettungsebene bei Ausfall des Identity Providers zu behalten.
