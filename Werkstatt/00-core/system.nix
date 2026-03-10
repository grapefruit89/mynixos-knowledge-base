# [META] ID: NIXH-CORE-036 | ADR: TBD | Version: 1.0 | Stage: 1
{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2.1 Metadaten (Audit Fix)
  nms = {
    id = "NIXH-00-COR-035-AUDIT";
    title = "System (SRE Boot & Security)";
    description = "systemd-boot tuning, i915 GuC/HuC activation, and kernel hardening.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["system/bootloader" "kernel/hardening" "intel/gpu-acceleration"];
    audit.last_reviewed = "2026-03-10";
    audit.complexity = 3;
  };
in {
  options.my.meta.system = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 15;
          editor = false;
        };
        efi.canTouchEfiVariables = true;
        grub.enable = false;
        timeout = 3;
      };
      
      # 🛡️ HARDWARE ACCELERATION (UHD 630)
      kernelParams = [ "i915.enable_guc=2" ];
      kernelModules = [ "i915" ];

      # 🛡️ KERNEL SELF-PROTECTION
      kernel.sysctl = {
        "net.ipv4.conf.all.rp_filter" = 1;
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.tcp_syncookies" = 1;
        "kernel.kptr_restrict" = 2;
        "kernel.dmesg_restrict" = 1;
        "kernel.unprivileged_bpf_disabled" = 1;
        # Extended hardening from Guide
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
      };
    };

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
    programs.nix-index-database.comma.enable = true;

    # 🧹 LEAN SYSTEM
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      nodejs_22
      alejandra
      git
      htop
      wget
      curl
      tree
      unzip
      file
      nix-output-monitor
      rsync
      hdparm
      pciutils
      usbutils
    ];

    environment.sessionVariables = {
      PATH = "/home/${config.my.configs.identity.user}/.npm-global/bin:$PATH";
    };

    programs.git = {
      enable = true;
      config = {
        core.hooksPath = "/etc/git-hooks";
        init.defaultBranch = "main";
      };
    };
  };
}
