{
  config,
  nix-index-database,
  ...
}: let
  inherit (config) flake;
in {
  flake.nixos.base.nix = {pkgs, ...}: {
    imports = [nix-index-database.nixosModules.nix-index flake.nixos.packages.nix];

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["https://cache.numtide.com"];
      extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
      trusted-users = ["@wheel"];
    };

    nixpkgs.overlays = [flake.overlays.default];

    programs = {
      nh.enable = true;
      nix-index-database.comma.enable = true;
      nix-ld = {
        enable = true;
        libraries = [pkgs.stdenv.cc.cc.lib];
      };
    };
  };

  flake.home.base.nix = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [nix-index-database.homeModules.nix-index flake.home.packages.nix];

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

  flake.nixosModules.default.imports = [flake.nixos.base.nix];
  flake.homeModules.default.imports = [flake.home.base.nix];
}
