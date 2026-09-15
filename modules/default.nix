{
  config,
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
    ./zfs-datasets.nix
    home-manager.nixosModules.home-manager
    nixos-wsl.nixosModules.wsl
  ];

  config = {
    security.sudo.wheelNeedsPassword = lib.mkDefault false;
    services.openssh.settings = lib.mkDefault {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    i18n = lib.mkDefault {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
    };
    programs = lib.mkDefault {
      nh.enable = true;
      nix-ld = {
        enable = true;
        libraries = with pkgs; [stdenv.cc.cc.lib];
      };
    };
    environment.systemPackages = lib.mkDefault (with pkgs; [
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
    nix.settings = lib.mkDefault {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel"];
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    };
  };
}
