let
  packages = pkgs: with pkgs; [deadnix nix-diff nix-init nix-output-monitor nix-search-tv nix-tree nix-update nurl];
in {
  flake.nixos.packages.nix = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
  flake.home.packages.nix = {pkgs, ...}: {home.packages = packages pkgs;};
}
