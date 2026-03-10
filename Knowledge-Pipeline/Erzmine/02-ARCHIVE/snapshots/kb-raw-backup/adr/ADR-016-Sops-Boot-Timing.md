---
title: ADR-016: Sops-Nix Boot Timing Fix
status: [ACCEPTED]
category: architecture/decision
---

# 🏛️ ADR-016: Sops-Nix Boot-Reihenfolge

## Kontext
Bei Nutzung von Impermanence und sops-nix besteht ein Race-Condition-Risiko: Secrets werden angefordert, bevor der SSH-Host-Key physisch auf /persist verfügbar ist.

## Entscheidung
Wir erzwingen die korrekte Abhängigkeit in der System-Konfiguration:
1. **Key-Mapping:** Wir nutzen \`sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];\`
2. **Systemd-Dependency:** Wir stellen sicher, dass der \`sops-install-secrets.service\` erst startet, wenn die persistente Partition gemountet ist.

## Begründung
Garantiert einen fehlerfreien Boot-Vorgang ohne manuellen Eingriff, selbst nach einem "Erase-your-darlings" Wipe des Root-Dateisystems.