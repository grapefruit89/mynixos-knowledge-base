# [META] ID: NIXH-GATE-014
# [META] TITLE: Tailscale (Zero-Trust Access)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-005, ADR-040]

{ config, lib, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    
    # ── AUTHENTICATION ────────────────────────────────────────────────────
    # Auth key is managed by sops-nix (NIXH-CORE-004)
    # [ADR-040] Associative Mining: verify key availability
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    
    # ── SETTINGS ──────────────────────────────────────────────────────────
    useRoutingFeatures = "server"; # Allow exit node & subnet routing
    extraUpFlags = [ 
      "--advertise-exit-node"
      "--ssh" # Native Tailscale SSH for recovery
    ];
  };

  # ── PERSISTENCE (Impermanence) ──────────────────────────────────────────
  # Tailscale state lives in /var/lib/tailscale (handled by NIXH-CORE-003)
}
