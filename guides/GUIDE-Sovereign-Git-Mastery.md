---
title: 🛠️ Sovereign Git Mastery (Layer 30-automation)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [self-hosted-git, ssh-only-forge, automated-dumps, code-sovereignty]
sources: [nixpkgs/pkgs/applications/version-management, forgejo docs, soft-serve]
---

# 🛠️ Code-Souveränität: Deine private Git-Infrastruktur

In mynixos sind wir nicht auf externe Plattformen angewiesen. Wir hosten unsere kritischen Repositories (Flakes, Secrets, ADRs) selbst.

## 🏛️ 1. Die SSoT-Wahl: Forgejo (The Full Forge)
Wir nutzen Forgejo als hocheffizienten GitHub-Ersatz.
- **Dienst:** \`services.forgejo.enable = true;\`
- **Nugget:** Wir nutzen \`services.forgejo.database.type = "sqlite3"\` für minimalen RAM-Verbrauch (Layer 20).
- **Backup:** \`services.forgejo.dump.enable = true\` schiebt tägliche Git-Snapshots auf Tier A (NVMe). ✅

## 💎 2. Der SRE-Weg: Soft-serve (SSH Only)
Für Puristen und extrem schnelle Workflows.
- **Konzept:** Ein Git-Server ohne HTTP-Overhead. Alles läuft über SSH.
- **Anwendung:** Ideal für die Synchronisation deiner \`mynixos-knowledge-base\` zwischen Server und Laptop.

## 🛡️ 3. Repo-Hygiene (Git-Filter-Repo)
Unser Werkzeug für den Ernstfall (SRE Tor 6).
- **Tool:** \`pkgs.git-filter-repo\`.
- **Anwendung:** Chirurgische Entfernung von sensiblen Daten aus der gesamten Git-Historie, falls Sops-Secrets versehentlich im Klartext committed wurden.

## 🚀 SRE-Vorteil
Eigene Git-Server folgen dem **Headless-Gesetz (ADR-010)** und dem **Efficiency-Mandat**. Sie geben dir die volle Kontrolle über deine geistige Arbeit.