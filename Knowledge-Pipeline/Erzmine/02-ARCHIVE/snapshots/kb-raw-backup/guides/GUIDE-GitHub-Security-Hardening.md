---
title: 🛡️ GitHub Security Hardening (SRE Tor 6)
category: architecture/security
status: [ACTIVE-SSoT]
capabilities: [secret-scanning, dependabot-automation, codeql-audit, security-advisories]
sources: [GitHub Security Documentation, Supply Chain Best Practices]
---

# 🛡️ GitHub Security: Das externe Schutzschild

Wir nutzen die Enterprise-Security-Features von GitHub, um die Integrität unserer Knowledge-Pipeline und des System-Codes zu garantieren.

## 🏛️ 1. Secret Scanning (The Emergency Brake)
Wir aktivieren das Secret-Scanning, um den Tower vor Datenlecks zu schützen.
- **Ziel:** Verhindern des Uploads unverschlüsselter SSH-Keys oder API-Tokens. ✅
- **Workflow:** Falls ein Secret erkannt wird, wird der Push sofort durch GitHub verweigert.

## 🤖 2. Dependabot Automation
Dependabot fungiert als dein automatisierter Junior-Admin.
- **Alerts:** Benachrichtigung bei CVEs in Flake-Inputs (via \`flake.lock\`).
- **Auto-Updates:** Automatische Pull-Requests für Sicherheits-Patches.

## 🔍 3. CodeQL Analysis (Static Analysis)
Wir integrieren CodeQL in unsere CI-Pipeline (Kapitel 72).
- **Nutzen:** Erkennt SQL-Injektionen, Cross-Site-Scripting oder unsichere Dateizugriffe in unseren Python/Bash-Hilfsscripten.

## 🛡️ 4. Security Policy
Wir hinterlegen eine \`SECURITY.md\` im Repo-Root.
- **Inhalt:** Klare Anweisungen für die Offenlegung von Schwachstellen.

## 🚀 SRE-Anwendung
Diese Einstellungen werden in den GitHub Repository-Settings unter "Security" permanent aktiviert. Sie bilden das externe Qualitäts-Tor 6 für mynixos.