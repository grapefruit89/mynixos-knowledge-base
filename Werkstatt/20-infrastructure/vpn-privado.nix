# [META] ID: NIXH-INFRA-009 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
let
  # [ADR-040]: Sovereign VPN Tunnel
  # Dieses Interface wird physisch in den Media-Vault Container geschoben.
  interface = "wg-privado";
in
{
  networking.wireguard.interfaces."${interface}" = {
    ips = [ "10.2.0.2/32" ]; # Dummy IP von Privado
    privateKeyFile = config.sops.secrets.wg_privado_private_key.path;

    peers = [
      {
        publicKey = "DUMMY_PUBLIC_KEY_VON_PRIVADO=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "DUMMY_SERVER_URL:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  # Wir stellen sicher, dass das Interface beim Booten da ist
  systemd.services."wireguard-${interface}" = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
  };
}
