# [META] ID: NIXH-SYS-054 | ADR: TBD | Version: 1.0 | Stage: 1
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.ragchat;
in {
  options.services.ragchat = {
    enable = mkEnableOption "MCP RAG-Chat Server";
    
    port = mkOption {
      type = types.port;
      default = 3456;
      description = "Port for the ragchat HTTP server.";
    };
    
    envFile = mkOption {
      type = types.str;
      default = "/root/.gemini/secrets.env";
      description = "Path to environment file containing GEMINI_API_KEY.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ragchat = {
      description = "MCP RAG-Chat Server Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      EnvironmentFile = cfg.envFile;
      
      environment = {
        PORT = toString cfg.port;
        LLM_PROVIDER = "gemini";
        LLM_MODEL = "gemini-2.0-flash";
      };

      serviceConfig = {
        # Using the compiled output from the knowledge pipeline
        ExecStart = "${pkgs.nodejs_20}/bin/node /home/Knowledge-Pipeline/mcp-ragchat/dist/mcp-server.js";
        Restart = "always";
        User = "root";
        WorkingDirectory = "/home/Knowledge-Pipeline/mcp-ragchat";
      };
    };
  };
}
