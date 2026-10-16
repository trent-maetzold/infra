{
  config,
  nix-index-database,
  ...
}: let
  inherit (config) my flake;

  nixos = {pkgs, ...}: {
    imports = [nix-index-database.nixosModules.nix-index];

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
    imports = [nix-index-database.homeModules.nix-index];

    agents.md.tools = ["- `nx`: run something that isn't installed, via `nix shell nixpkgs#...`: `nx jq ripgrep -- jq --version`. Packages before `--`, command after; without `--` it opens a shell."];

    # A script, not an alias, so non-interactive agent shells get it.
    home.packages = [
      (pkgs.writeShellScriptBin "nx" ''
        pkgs=()
        while [ $# -gt 0 ] && [ "$1" != -- ]; do pkgs+=("nixpkgs#$1"); shift; done
        [ ''${#pkgs[@]} -gt 0 ] || { echo "usage: nx PKG... [-- CMD ARGS...]" >&2; exit 1; }
        if [ "''${1:-}" = -- ]; then
          shift
          exec nix shell "''${pkgs[@]}" -c "$@"
        fi
        exec nix shell "''${pkgs[@]}"
      '')
    ];

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
  # Modules
  my.modules.base.nix = {inherit home nixos;};

  # NixOS Modules
  flake.nixosModules.default.imports = [my.modules.base.nix.nixos];

  # Home Manager Modules
  flake.homeModules.default.imports = [my.modules.base.nix.home];
}
