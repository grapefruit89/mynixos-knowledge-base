---
title: 🛡️ Service Hardening & Sandboxing (Layer 90-policy)
category: architecture/security
status: [ACTIVE-SSoT]
capabilities: [process-isolation, cve-scanning, secure-hashing, sandboxing]
sources: [nixpkgs/pkgs/tools/security, Google nsjail docs, CVE-bin-tool]
---

# 🛡️ Hardening: Isolation als Standard

In mynixos gehen wir davon aus, dass jede Web-App (Layer 40/50) potenziell kompromittierbar ist. Wir minimieren den Schaden durch strikte Isolation.

## 🏛️ 1. Prozess-Isolation via nsjail (The Prison)
Wir nutzen \`nsjail\`, um Dienste in einen hochgradig eingeschränkten Namespace zu sperren.
- **Dienst:** \`pkgs.nsjail\`.
- **SRE-Vorteil:** Begrenzt Dateisystem-Zugriff, Netzwerk-Schnittstellen und System-Calls (Seccomp). ✅
- **Anwendung:** Besonders wichtig für Dienste, die untrusted Daten verarbeiten (z.B. SABnzbd oder n8n).

## 🔍 2. Proaktives CVE-Scanning
Wir nutzen \`cve-bin-tool\`, um den Status unserer Binaries zu überwachen.
- **Pattern:** Ein wöchentlicher systemd-Timer triggert einen Scan über \`/run/current-system/sw/bin\`.
- **Alerting:** Warnungen werden direkt an Matrix (Kapitel 20) gesendet.

## 🔑 3. Password-Security (\`mkpasswd\`)
User-Passwörter in der NixOS-Konfiguration (\`users.users.<name>.passwordHash\`) werden ausschließlich als Hashes hinterlegt.
- **Befehl:** \`mkpasswd -m sha-512\` (oder moderner Argon2).
- **Vorteil:** Selbst wenn deine \`flake.nix\` öffentlich wird, sind deine Passwörter sicher. ✅

## 🚀 SRE-Anwendung
Das Ziel ist "Defense in Depth". Falls die Firewall (Kapitel 56) und SPA (Kapitel 61) überwunden werden, verhindert das Sandboxing den Zugriff auf das restliche System.