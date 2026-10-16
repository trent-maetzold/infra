{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [harlequin tredis];
  };
in {
  # Modules
  my.modules.packages.data.home = out;

  # Home Manager Modules
  flake.homeModules.data.imports = [config.my.modules.packages.data.home];
}
