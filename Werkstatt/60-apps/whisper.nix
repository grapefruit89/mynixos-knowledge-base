# [META] ID: NIXH-SYS-032 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-60-APP-015";
    title = "Whisper STT (Aviation-Grade KI)";
    description = "High-performance C++ Speech-to-Text engine with API-Server for Mobile Dictation and Home Assistant Wyoming integration.";
    layer = 60;
    nixpkgs.category = "services/ai";
    capabilities = [ "ai/stt" "api/openai-compatible" "home-assistant/wyoming" ];
    audit.last_reviewed = "2026-03-10";
    audit.complexity = 3;
  };

  port = config.my.ports.whisper or 10016; # Wir registrieren den Port später in ports.nix
  domain = config.my.configs.identity.domain;
  modelPath = "/var/lib/whisper/models/ggml-base.bin";
in
{
  options.my.services.whisper.enable = lib.mkEnableOption "Whisper STT Service";

  config = lib.mkIf config.my.services.whisper.enable {
    
    # 1. WHISPER-CPP SERVER (Für Android Keyboard & Mobile)
    # Wir nutzen eine systemd-unit, da whisper-cpp server oft manuell konfiguriert wird
    systemd.services.whisper-server = {
      description = "Whisper.cpp OpenAI-Compatible API Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.whisper-cpp}/bin/whisper-cpp-server -m ${modelPath} --port ${toString port} --host 127.0.0.1";
        Restart = "always";
        # 🛡️ Aviation-Grade Hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        DynamicUser = true;
        StateDirectory = "whisper";
      };
    };

    # 2. WYOMING-WHISPER (Für Home Assistant)
    # Erlaubt Home Assistant die direkte Nutzung der Engine
    services.wyoming.whisper = {
      enable = true;
      servers = {
        "home-assistant" = {
          enable = true;
          address = "127.0.0.1";
          port = 10300; # Standard Wyoming Port
          model = "base";
          language = "de";
        };
      };
    };

    # 3. REVERSE PROXY (Caddy Ingress)
    # Erlaubt den Zugriff vom Handy via Tailscale/Internet
    services.caddy.virtualHosts."stt.${domain}" = {
      extraConfig = ''
        import sso_auth
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };

    # SRE: Port-Registrierung (Dummy zur Erinnerung)
    # TODO: In 00-core/ports.nix eintragen: whisper = 10016;
  };
}
