# [META] ID: NIXH-SYS-018 | ADR: TBD | Version: 1.0 | Stage: 1
{ ... }: { imports = [ ./service-app-couchdb.nix ./service-app-filebrowser.nix ./service-app-filebrowser-native.nix ./service-app-karakeep.nix ./service-app-matrix-conduit.nix ./service-app-monica.nix ./service-app-vaultwarden.nix ./service-app-sftpgo.nix ./service-app-microbin.nix
    ./whisper.nix
  ];
}
