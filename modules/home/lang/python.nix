{config, ...}: {
  flake.home.lang.python = {pkgs, ...}: {
    home.packages = with pkgs; [basedpyright python3 python3Packages.debugpy ruff uv];
    programs.lazyvim.extras.lang.python.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.lang.python];
}
