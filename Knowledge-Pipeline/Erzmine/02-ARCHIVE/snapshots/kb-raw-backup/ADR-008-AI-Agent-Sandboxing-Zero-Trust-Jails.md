---
id: ADR-008
title: AI Agent Sandboxing (Zero-Trust Jails)
status: accepted
date: 2026-03-10
tags: [ai, security, sandboxing, bubblewrap, jailed-agents, zero-trust]
---

# ADR-008: AI Agent Sandboxing (Zero-Trust Jails)

## 1. USER LAYER (KISS)
Wenn du KI-Agenten (wie Claude Code) erlaubst, Dateien auf deinem System zu lesen oder Befehle auszuführen, ist das ein Sicherheitsrisiko. Wir nutzen daher ein "Gefängnis" (Jail) für diese Agenten. Durch **jailed-agents** (basierend auf Bubblewrap) wird der Agent in eine isolierte Blase gesperrt. Er sieht nur die Ordner und Programme, die er für seine Aufgabe wirklich braucht. Deine privaten Dateien, Passwörter und SSH-Schlüssel bleiben für die KI unsichtbar und unerreichbar.

## 2. TECHNICAL LAYER (Specification)

### Die Sandboxing-Technologie (Bubblewrap)
Anstatt schwerfälliger Docker-Container nutzen wir **Bubblewrap** (unprivileged unshared user namespaces). Dies ist der Goldstandard für Linux-Sandboxing.

#### Implementierungs-Muster (Dendritic Module):
Wir integrieren das Jail direkt in den AI-Agent-Dendriten (`ai-agents.nix`).

```nix
{ pkgs, ... }:
let
  # Wir wickeln den Agenten in ein Bubblewrap-Jail
  jailed-claude = pkgs.writeShellScriptBin "jailed-claude" """
    ${pkgs.bubblewrap}/bin/bwrap \\
      --ro-bind /nix /nix \\
      --dev /dev \\
      --proc /proc \\
      --tmpfs /tmp \\
      --dir /var \\
      --bind . . \\
      --unshare-all \\
      --share-net \\
      --hostname ai-sandbox \\
      ${pkgs.nodejs_22}/bin/npx -y @anthropic-ai/claude-code
  """;
in
{
  environment.systemPackages = [ jailed-claude ];
}
```

#### Sicherheits-Garantien:
1.  **Dateisystem-Isolation:** Nur der aktuelle Arbeitsordner (`--bind . .`) ist beschreibbar. Der Rest des Systems ist entweder unsichtbar oder nur lesbar (`--ro-bind /nix`).
2.  **Identitäts-Schutz:** Der Agent sieht keine Benutzerinformationen oder Umgebungsvariablen (`--unshare-all`).
3.  **Netzwerk-Kontrolle:** Der Zugriff kann bei Bedarf komplett deaktiviert werden (`--unshare-net`).

## 3. REASONING LAYER (ADR)

### Warum Bubblewrap statt Docker?
- **Sicherheit:** Docker-Container laufen oft als Root-Prozesse und haben eine große Angriffsfläche. Bubblewrap ist unprivilegiert und nutzt native Linux-Sicherheitsfeatures.
- **Integration:** Wir können dem Agenten punktgenau Nix-Pakete zur Verfügung stellen, ohne ein Docker-Image vorab bauen zu müssen (Just-in-Time Environment).

### Warum "Jailed Agents" (Andersonjoseph)?
Das Projekt bietet eine saubere Nix-Abstraktion (`jail.nix`) für diese komplexe Bubblewrap-Logik. Es passt perfekt zu unserem **Dendritic-Pattern**, da wir das Jail direkt als Teil des Dienst-Moduls definieren können.

### Alternativen (Verworfen):
- **Native Härtung (`ProtectHome=true`):** Gut für Hintergrunddienste, aber nicht ausreichend für interaktive KI-Agenten, die Dateizugriff benötigen.
- **Virtuelle Maschinen:** Zu hoher Ressourcenverbrauch für einfache Coding-Aufgaben.

---
> [ARCHITECT-NOTE]: Inspiriert von Andersonjoseph/jailed-agents (v2026.03.10)
