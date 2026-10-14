{
  config,
  nix-index-database,
  ...
}: let
  inherit (config) features flake;
  nixos = {pkgs, ...}: {
    imports = [nix-index-database.nixosModules.nix-index features.nixos.packages.nix];

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
      trusted-users = ["@wheel"];
    };

    nixpkgs.overlays = builtins.attrValues flake.overlays;

    programs = {
      nh.enable = true;
      nix-index-database.comma.enable = true;
      nix-ld = {
        enable = true;
        libraries = [pkgs.stdenv.cc.cc.lib];
      };
    };
  };
  home = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [nix-index-database.homeModules.nix-index features.home.packages.nix];

    programs = {
      nh.enable = true;
      nix-index-database.comma.enable = true;
      nix-init = {
        enable = true;
        settings = {
          commit = true;
          access-tokens."github.com".command = lib.mkIf config.programs.gh.enable ["gh" "auth" "token"];
        };
      };
      nix-search-tv.enable = true;
    };
  };
in {
  # Features
  features.nixos.base.nix = nixos;
  features.home.base.nix = home;

  # NixOS Modules
  flake.nixosModules.default.imports = [features.nixos.base.nix];

  # Home Manager Modules
  flake.homeModules.default.imports = [features.home.base.nix];
}
