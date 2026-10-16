{config, ...}: let
  packages = pkgs: with pkgs; [deadnix nix-diff nix-init nix-output-monitor nix-search-tv nix-tree nix-update nurl];
  nixos = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
  home = {pkgs, ...}: {home.packages = packages pkgs;};
in {
  # Modules
  my.modules.packages.nix = {inherit home nixos;};

  # NixOS Modules
  flake.nixosModules.default.imports = [config.my.modules.packages.nix.nixos];

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.packages.nix.home];
}
