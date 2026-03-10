---
title: ADR-006: Secret Management Standard (Refined)
status: [ACCEPTED]
category: architecture/decision
capabilities: [automated-decryption, zero-touch-deployment, nix-native]
sources: [Internal SRE Audit, User Feedback]
---

# 🏛️ ADR-006: sops-nix für Zero-Touch Deployment

## Kontext
Vergleich zwischen \`git-crypt\` und \`sops-nix\`. Physischer Zugriffsschutz ist durch den User garantiert.

## Entscheidung
Wir bleiben bei **sops-nix**.

## Neue Begründung (Aviation-Grade Automation)
1.  **Boot-Automation:** \`sops-nix\` erlaubt die Entschlüsselung via Host-Key (SSH/Age) ohne menschliche Interaktion. \`git-crypt\` erfordert ein manuelles "Unlock", was dem **Stick-Ready Mandat** widerspricht.
2.  **Systemd-Mapping:** \`sops-nix\` spiegelt Secrets direkt in das flüchtige RAM-Filesystem (\`/run/secrets\`) und setzt dabei automatisch die korrekten Linux-Berechtigungen (Owner/Group) für den jeweiligen Dienst (z.B. Caddy).
3.  **No-Decryption-on-Storage:** Auch wenn der Host sicher ist, ist es sauberer, wenn Secrets niemals permanent auf der SSD liegen, sondern nur im flüchtigen Speicher existieren.

## Konsequenz
\`sops-nix\` ist das einzige Tool, das einen vollautomatisierten Reboot des Towers ohne manuelles Eingreifen ermöglicht.