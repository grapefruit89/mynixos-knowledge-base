# [GUIDE]: Agent-Jailing mit Bubblewrap
# ID: [NUGGET-SRE-012] | Status: ACTIVE | Stand: 10.03.2026

## 1. Das Jail-Prinzip
Wir nutzen `bubblewrap`, um flüchtige Prozesse (Agenten, Scripte) so einzusperren, dass sie nur das sehen, was sie für ihre Aufgabe brauchen.

## 2. Die drei Jail-Modi

### 🛡️ Modus A: Deep Freeze (Maximale Sicherheit)
Kein Internet, kein Schreibzugriff auf das System, nur flüchtiger Speicher.
```bash
bwrap --unshare-all --tmpfs / --ro-bind /nix/store /nix/store --proc /proc /bin/sh
```

### 🛡️ Modus B: The Researcher (Mit Internet)
Nur Lesezugriff auf das System, aber Netzwerkverbindung erlaubt (für API-Calls).
```bash
bwrap --unshare-all --share-net --tmpfs / --ro-bind /nix/store /nix/store --ro-bind /etc/resolv.conf /etc/resolv.conf --proc /proc /bin/sh
```

### 🛡️ Modus C: The Artisan (Mit Projekt-Mount)
Wie Modus B, aber ein spezifischer Ordner (z.B. die Werkstatt) wird schreibbar gemountet.
```bash
bwrap --unshare-all --share-net --tmpfs / --bind /home/Werkstatt /home/Werkstatt --ro-bind /nix/store /nix/store --proc /proc /bin/sh
```

## 3. Strategische Empfehlung
Jeder neue MCP-Server oder Test-Agent sollte standardmäßig im **Modus B** gestartet werden, um die System-Purity zu wahren.

---
> [SOURCE]: https://github.com/andersonjoseph/jailed-agents & ADR-008
