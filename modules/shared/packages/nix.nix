let
  packages = pkgs: with pkgs; [deadnix nix-diff nix-init nix-output-monitor nix-search-tv nix-tree nix-update nurl];
  nixos = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
  home = {pkgs, ...}: {home.packages = packages pkgs;};
in {
  # Features
  features.nixos.packages.nix = nixos;
  features.home.packages.nix = home;
}
