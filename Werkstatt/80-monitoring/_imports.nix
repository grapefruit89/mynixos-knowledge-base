# [META] ID: NIXH-SYS-035 | ADR: TBD | Version: 1.0 | Stage: 1
{
  imports = [
    ./gatus.nix
    ./cockpit.nix
    ./service-netdata.nix
    ./service-scrutiny.nix
    ./ntfy-alerting.nix
     # ./uptime-kuma.nix [DEPRECATED by ADR-022]
  ];
}