{config, ...}: let
  packages = pkgs: with pkgs; [tmux];
in {
  flake.nixos.packages.terminal = {pkgs, ...}: {
    environment.systemPackages = packages pkgs;
  };
  flake.home.packages.terminal = {pkgs, ...}: {
    home.packages = packages pkgs;
  };
  flake.nixosModules.default.imports = [config.flake.nixos.packages.terminal];
  flake.homeModules.default.imports = [config.flake.home.packages.terminal];
}
