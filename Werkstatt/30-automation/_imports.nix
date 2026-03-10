# [META] ID: NIXH-SYS-003 | ADR: TBD | Version: 1.0 | Stage: 1
{
  imports = [
    ./matrix.nix
    ./automation.nix
    ./service-app-ai-agents.nix
    ./service-app-ai-tools.nix
    ./service-app-home-assistant.nix
    ./service-app-n8n.nix
    ./service-app-olivetin.nix
    ./service-app-semaphore.nix
  ];
}