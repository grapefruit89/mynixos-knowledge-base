# [META] ID: NIXH-INFRA-002 | ADR: TBD | Version: 1.0 | Stage: 1
{
  imports = [
    ./clamav.nix
    ./postgresql.nix
    ./secret-ingest.nix
    ./service-app-zigbee-stack.nix
    ./valkey.nix
    # ./vpn-confinement.nix
    # ./vpn-live-config.nix
  ];
}