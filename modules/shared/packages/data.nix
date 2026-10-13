{config, ...}: let
  packages = pkgs: with pkgs; [harlequin jq tredis];
in {
  flake.nixos.packages.data = {pkgs, ...}: {
    environment.systemPackages = packages pkgs;
  };
  flake.home.packages.data = {pkgs, ...}: {
    home.packages = packages pkgs;
  };
  flake.nixosModules.default.imports = [config.flake.nixos.packages.data];
  flake.homeModules.default.imports = [config.flake.home.packages.data];
}
