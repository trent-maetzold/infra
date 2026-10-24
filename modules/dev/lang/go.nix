# Go toolchain, gopls and delve.
{config, ...}: let
  modules.home = {pkgs, ...}: {
    home.packages = with pkgs; [delve go gopls gotools];
    programs.lazyvim.extras.lang.go.enable = true;
  };
in {
  # Flake Modules
  flake.modules.homeManager.lang-go = modules.home;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.lang-go];
}
