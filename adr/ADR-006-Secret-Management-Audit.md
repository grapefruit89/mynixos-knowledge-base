---
title: ADR-006: Secret Management Standard (sops-nix vs. git-crypt)
status: [ACCEPTED]
category: architecture/decision
capabilities: [secret-encryption, git-safety, nix-integration]
sources: [https://blog.ktz.me/keeping-secrets-secret-with-git-crypt/, Internal Security Audit]
---

# 🏛️ ADR-006: sops-nix als Aviation-Grade Standard

## Kontext
Wir haben \`git-crypt\` als alternative Methode zur Secret-Verschlüsselung analysiert (basiert auf ironicbadger's Historie).

## Entscheidung
Wir bleiben strikt bei **sops-nix** mit **age**. \`git-crypt\` wird als Legacy-Option verworfen.

## Begründung (The Hard Facts)
1.  **Disk-Security:** \`git-crypt\` hinterlässt Klartext-Dateien im Arbeitsverzeichnis. \`sops-nix\` hält Secrets bis zur Aktivierung verschlüsselt.
2.  **Menschliches Versagen:** Alex Kretzschmar berichtet von mehrfachen Leaks durch Fehlkonfiguration der \`.gitattributes\`. Das \`sops\`-Workflow-Modell (explizites Editieren) ist inhärent sicherer.
3.  **Granularität:** Mit \`sops-nix\` können wir pro Dienst entscheiden, wer welche Datei lesen darf, ohne das gesamte Repo zu entschlüsseln.

## Was wir von git-crypt lernen
- Das Prinzip der **transparenten Verschlüsselung** ist bequem, aber gefährlich für SRE-Prozesse.
- Die Nutzung von **GPG** ist mächtig, aber **age** (unser Standard) ist moderner, schneller und einfacher zu verwalten.

## Konsequenz
Alle Geheimnisse (API-Keys, Passwörter) werden ausschließlich in \`secrets.yaml\` via sops verwaltet.