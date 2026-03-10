---
title: ⚡ NVMe over TCP: Ultra-High-Speed Network Storage (Layer 20-server)
category: architecture/storage
status: [PROPOSED]
capabilities: [network-nvme, low-latency-storage, cluster-backbone, nvme-of]
sources: [ipv64.net (Dennis Schröder), Linux NVMe-oF Documentation]
---

# ⚡ NVMe over TCP: Das Rückgrat deines Clusters

In mynixos nutzen wir NVMe over TCP (NVMe-oF), um die brachiale Leistung unserer NVMe-SSDs (Tier A) über das Netzwerk zu teilen.

## 🏛️ 1. Das Konzept (Aviation-Grade Storage)
Anstatt langsame Dateifreigaben (NFS/SMB) für Datenbanken zu nutzen, reichen wir die rohen Block-Devices durch.
- **Target:** Der Server, der die physische NVMe besitzt.
- **Initiator:** Der Client, der die NVMe über das Netzwerk einbindet.

## ⚙️ 2. NixOS Implementierung (Vorschau)
NixOS bietet die nötigen Kernel-Module und Werkzeuge (\`nvme-cli\`) nativ an.

### Target-Konfiguration (Der Geber):
\`\`\`nix
boot.kernelModules = [ "nvmet" "nvmet-tcp" ];
# Die Konfiguration erfolgt über das nvmet-cli Tool oder systemd-Services
\`\`\`

### Initiator-Konfiguration (Der Nehmer):
\`\`\`nix
boot.kernelModules = [ "nvme-tcp" ];
environment.systemPackages = [ pkgs.nvme-cli ];
# Einbindung via: nvme connect -t tcp -a <IP> -n <nqn>
\`\`\`

## 🚀 SRE-Vorteil
- **Latenz:** Fast identisch zu lokalem Speicher. ✅
- **Zentralisierung:** Alle kritischen States (Datenbanken) können physisch auf einem gesicherten Host liegen, während die Rechenlast auf mehrere Knoten verteilt wird.
- **Efficiency:** Nutzt vorhandene Ethernet-Hardware (idealerweise 2.5 Gbit/s Switches aus Kapitel 80).

## 🛡️ Sicherheit
NVMe-oF wird innerhalb des geschützten **VLANs** oder via **Tailscale-Tunnel** betrieben, um den unbefugten Zugriff auf die rohen Daten zu verhindern.