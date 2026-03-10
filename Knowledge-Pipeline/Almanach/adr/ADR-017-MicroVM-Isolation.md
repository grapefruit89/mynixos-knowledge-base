# [ADR-017]: MicroVM Isolation Baseline
# ID: [NUGGET-NIX-001] | Status: ACCEPTED | Stand: 10.03.2026

## 1. Context (User Layer)
Docker ist verboten. Native NixOS-Services (wie systemd) sind gut, teilen sich aber den Kernel mit dem Host. Für extrem kritische Dienste (wie Vaultwarden/Passwörter oder Pocket-ID) reicht das nicht. Wenn der Dienst gehackt wird, darf der Angreifer nicht auf den Host ausbrechen.

## 2. Decision (Technical Layer)
Wir nutzen `astro/microvm.nix` für "Aviation-Grade" Sandboxing.
- Kritische Dienste laufen in einer winzigen, leichtgewichtigen virtuellen Maschine (MicroVM).
- Jede MicroVM hat einen eigenen Kernel.
- Der `/nix/store` des Hosts wird Read-Only via `virtiofs` in die VM gemountet, wodurch die VM fast keinen eigenen Speicherplatz verbraucht und in <500ms bootet.

### 2.1 Umsetzung in der Werkstatt (Zukunft)
```nix
# Flake Input hinzufügen:
# microvm.url = "github:astro/microvm.nix";

# In einer Service-Datei (z.B. 60-apps/vaultwarden-vm.nix):
microvm.vms.vaultwarden = {
  specialArgs = { inherit inputs; };
  config = {
    system.stateVersion = "25.11";
    microvm.volumes = [ {
      mountPoint = "/var/lib/bitwarden_rs";
      image = "/persist/vms/vaultwarden.img";
      size = 1024;
    } ];
    services.vaultwarden.enable = true;
  };
};
```

## 3. Reasoning (Reasoning Layer)
- **Extreme Sicherheit:** Selbst ein Kernel-Exploit im Gastsystem kompromittiert den Host nicht.
- **Ressourcen-Effizienz:** Da der Nix-Store geteilt wird, ist der RAM- und CPU-Overhead im Vergleich zu klassischen VMs (Proxmox/Unraid) verschwindend gering.
- **Perfekt für Dendritic:** Die VM-Konfiguration kann in der gleichen Datei leben wie die Host-Proxy-Regel (Caddy).
