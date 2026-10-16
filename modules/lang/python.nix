{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [basedpyright python3 python3Packages.debugpy ruff uv];
    programs.lazyvim.extras.lang.python.enable = true;
  };
in {
  # Modules
  my.modules.lang.python.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.lang.python.home];
}
