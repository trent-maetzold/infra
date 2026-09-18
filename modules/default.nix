{
  lib,
  pkgs,
  home-manager,
  nixos-wsl,
  ...
}: {
  imports = [
    ./home-manager.nix
    ./llama-swap
    ./wsl.nix
    home-manager.nixosModules.home-manager
    nixos-wsl.nixosModules.wsl
  ];

  config = {
    security.sudo.wheelNeedsPassword = lib.mkDefault false;
    services.openssh.settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault false;
    };
    i18n = {
      defaultLocale = lib.mkDefault "en_US.UTF-8";
      # mkDefault on each leaf, never on the attrset: a whole-value default on a
      # submodule-typed option is dropped as soon as any other module defines a
      # nested path inside it.
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
    programs.nh.enable = lib.mkDefault true;
    programs.nix-ld = {
      enable = lib.mkDefault true;
      libraries = with pkgs; [stdenv.cc.cc.lib];
    };
    environment.systemPackages = lib.mkAfter (with pkgs; [
      gcc
      gnumake
      just
      pkg-config

      alejandra
      curl
      git
      openssh
      openssl
      tree
      unzip
      wget
    ]);
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = lib.mkAfter ["@wheel"];
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    };
  };
}
