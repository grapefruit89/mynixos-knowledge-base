# [META] ID: NIXH-GATE-008 | ADR: TBD | Version: 1.0 | Stage: 1
{ ... }:
{
  imports = [
    ./adguardhome.nix
    ./caddy.nix
    ./cloudflared-tunnel.nix
    ./ddns-updater.nix
    ./dns-automation.nix
    # ./dns-map.nix  # KEIN MODUL (wird direkt importiert)
    ./homepage.nix
    ./landing-zone-ui.nix
    ./pocket-id.nix
    ./sso.nix
    ./tailscale.nix
  ];
}
