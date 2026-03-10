# [ADR-010]: Impermanence Strategy & Ephemeral Root
# ID: [NUGGET-NIX-001] | Status: ACCEPTED | Stand: 10.03.2026

## 1. Context (User Layer)
NixOS ist deklarativ, aber "State" sammelt sich trotzdem an (Logs, Caches, alte Configs). Um echte SSoT (Single Source of Truth) zu erzwingen, muss das System bei jedem Neustart "vergessen", was nicht explizit gespeichert werden soll.

## 2. Decision (Technical Layer)
Wir implementieren das "Ephermeral Root" Pattern via `nix-community/impermanence`. 
- `/` (Root) wird bei jedem Boot gelöscht (ZFS blank snapshot oder tmpfs).
- `/persist` ist der einzige Ort, an dem Daten überleben.
- `/nix` bleibt unangetastet (hier lebt das System).

### 2.1 Umsetzung in der Werkstatt (Zukunft)
```nix
environment.persistence."/persist" = {
  hideMounts = true;
  directories = [
    "/var/log"
    "/var/lib/nixos"
    "/var/lib/systemd/coredump"
    "/etc/NetworkManager/system-connections"
  ];
  files = [
    "/etc/machine-id"
    { file = "/var/keys/secret_file"; parentDirectory = { mode = "0700"; }; }
  ];
};
```

## 3. Reasoning (Reasoning Layer)
- Malware verliert nach einem Reboot den Halt im System.
- Konfigurations-Drift ist physisch unmöglich.
- Erleichtert Backups, da `/persist` 100% des State enthält.
