# [META] ID: NIXH-SYS-051 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos Secret Management (sops-nix & age) ---
 * Manages the decryption of secrets at runtime.
 */
{ config, lib, pkgs, ... }:

{
  # 1. Definiere den Ort der zentralen Geheimnis-Datei
  sops.defaultSopsFile = ../secrets/secrets.yaml;

  # 2. Definiere den privaten Schlüssel, der zum Entschlüsseln genutzt wird
  # Dieser Pfad muss über `impermanence` persistent gemacht werden.
  sops.age.keyFile = "/persist/secrets/age.key";

  # 3. Gib dem `root`-User und wichtigen Diensten Zugriff auf den Schlüssel
  sops.age.sshKeyPaths = []; # Wir nutzen age, nicht ssh
  sops.age.secrets = {
    # Erlaube dem `root`-User, auf den Schlüssel zuzugreifen
    root_user_key = {
      path = config.sops.age.keyFile;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  # 4. Aktiviere sops für den NixOS-Daemon und den Host
  sops.nixpkgs.collection = ../secrets/secrets.yaml;
  sops.secrets = {
    # Hier werden später die spezifischen Geheimnisse für Dienste definiert
    # Beispiel:
    # "postgresql_password" = {
    #   owner = "postgres";
    #   group = "postgres";
    # };
  };
}
