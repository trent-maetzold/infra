{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [harlequin tredis];
  };
in {
  # Features
  features.home.packages.data = out;

  # Home Manager Modules
  flake.homeModules.data.imports = [config.features.home.packages.data];
}
