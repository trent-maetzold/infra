{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [basedpyright python3 python3Packages.debugpy ruff uv];
    programs.lazyvim.extras.lang.python.enable = true;
  };
in {
  # Features
  features.home.lang.python = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.lang.python];
}
