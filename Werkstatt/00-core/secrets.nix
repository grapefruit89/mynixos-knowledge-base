# [META] ID: NIXH-CORE-004
# [META] TITLE: Secret Management (Sops-Nix)
# [META] STAGE: 2 (Nugget)
# [META] VERSION: 1.1
# [META] REQ_REFS: [ADR-032, ADR-034]

{ config, lib, pkgs, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    # [ADR-032] Sovereign Key Location (survives Impermanence wipe)
    age = {
      keyFile = "/persist/secrets/age.key";
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = true;
    };

    # ── GLOBAL SECRETS ───────────────────────────────────────────────────
    secrets = {
      # Infrastructure
      "wg_privado_private_key" = { owner = "root"; };
      "cloudflare_api_token" = { owner = "caddy"; };
      
      # [ADR-034] Media-Stack Keys (Used by api-injection-factory)
      "sonarr_api_key" = { owner = "sonarr"; };
      "radarr_api_key" = { owner = "radarr"; };
      "prowlarr_api_key" = { owner = "prowlarr"; };
      
      # Identity
      "pocketid_oidc_secret" = { owner = "pocket-id"; };
    };
  };

  # Dependency: sops-nix is required for these secrets to be available
  # environment.systemPackages = [ pkgs.sops pkgs.age ];
}
