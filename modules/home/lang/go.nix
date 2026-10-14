{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [delve go gopls gotools];
    programs.lazyvim.extras.lang.go.enable = true;
  };
in {
  # Features
  features.home.lang.go = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.lang.go];
}
