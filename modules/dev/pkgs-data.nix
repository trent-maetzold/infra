# Database TUIs: harlequin (SQL), tredis (Redis).
{config, ...}: let
  modules.home = {pkgs, ...}: {
    home.packages = with pkgs; [harlequin tredis];
  };
in {
  # Flake Modules
  flake.modules.homeManager.pkgs-data = modules.home;

  # Home Configuration Modules
  flake.homeModules.data.imports = [config.flake.modules.homeManager.pkgs-data];
}
