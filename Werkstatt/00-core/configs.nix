# [META] ID: NIXH-CORE-006 | ADR: TBD | Version: 1.0 | Stage: 1
{
  lib,
  config,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten (Aviation-Grade)
  nms = {
    id = "NIXH-00-COR-008";
    title = "Configs (SRE Master Source)";
    description = "Central source of truth for global identity, hardware toggles and SRE quotas with strict type validation.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["ssot/master" "sre/quotas"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };
in {
  imports = [
    # ../20-infrastructure/vpn-live-config.nix
  ];

  options.my.meta.configs = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for configs module";
  };

  options.my.configs = {
    # ── BASTELMODUS ──────────────────────────────────────────────────────────
    bastelmodus = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Master switch for insecure debug mode (Firewall OFF, Passwordless Sudo).";
    };

    # ── IDENTITY ───────────────────────────────────────────────────────────
    identity = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "q958";
      };
      domain = lib.mkOption {
        type = lib.types.str;
        default = "m7c5.de";
      };
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "nix";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "moritzbaumeister@gmail.com";
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = "moritz";
      };
    };

    # ── SERVER ──────────────────────────────────────────────────────────────
    server = {
      lanIP = lib.mkOption {
        type = lib.types.str;
        default = "192.168.2.73";
        description = "Lokale IP des Servers im Heimnetz.";
      };
      tailscaleIP = lib.mkOption {
        type = lib.types.str;
        default = "100.113.29.82";
        description = "Tailscale IP des Servers (100.x.y.z).";
      };
    };

    # ── NETWORK ────────────────────────────────────────────────────────────
    network = {
      lanCidrs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["192.168.0.0/16" "10.0.0.0/8" "172.16.0.0/12"];
      };
      tailnetCidrs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["100.64.0.0/10"];
      };
      dnsDoH = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "https://dns.cloudflare.com/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
      };
      dnsBootstrap = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["9.9.9.9" "1.1.1.1"];
      };
      dnsFallback = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["9.9.9.9" "1.1.1.1"];
      };
    };

    # ── HARDWARE ────────────────────────────────────────────────────────────
    hardware = {
      cpuType = lib.mkOption {
        type = lib.types.enum ["intel" "amd" "arm"];
        default = "intel";
      };
      intelGpu = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      zigbeeStickIP = lib.mkOption {
        type = lib.types.str;
        default = "192.168.2.46";
      };
      ramGB = lib.mkOption {
        type = lib.types.int;
        default = 16;
      };
    };
  };
}
