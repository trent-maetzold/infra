{
  config,
  lib,
  pkgs,
  home-manager,
  nixos-wsl,
  ...
}: let
  cfg = config.asgard;
in {
  imports = [
    ./home-manager.nix
    ./llama-swap
    ./podman.nix
    ./wsl.nix
    home-manager.nixosModules.home-manager
    nixos-wsl.nixosModules.wsl
  ];

  config = lib.mkMerge [
    {asgard.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      environment.systemPackages = lib.mkAfter (with pkgs; [
        alejandra
        curl
        gcc
        git
        gnumake
        just
        openssh
        openssl
        pkg-config
        tree
        unzip
        wget
      ]);
      i18n = {
        defaultLocale = lib.mkDefault "en_US.UTF-8";
        extraLocaleSettings = lib.genAttrs [
          "LC_ADDRESS"
          "LC_IDENTIFICATION"
          "LC_MEASUREMENT"
          "LC_MONETARY"
          "LC_NAME"
          "LC_NUMERIC"
          "LC_PAPER"
          "LC_TELEPHONE"
          "LC_TIME"
        ] (_: lib.mkDefault "en_US.UTF-8");
      };
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        extra-substituters = ["https://cache.numtide.com"];
        extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
        trusted-users = lib.mkAfter ["@wheel"];
      };
      programs.nh.enable = lib.mkDefault true;
      programs.nix-ld = {
        enable = lib.mkDefault true;
        libraries = with pkgs; [stdenv.cc.cc.lib];
      };
      security.sudo.wheelNeedsPassword = lib.mkDefault false;
      services.openssh.settings = {
        PasswordAuthentication = lib.mkDefault false;
        PermitRootLogin = lib.mkDefault "no";
      };
    })
  ];

  options.asgard.enable = lib.mkEnableOption "asgard's base NixOS defaults";
}
