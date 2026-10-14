{config, ...}: {
  flake.home.editor.lang.python = {
    imports = [config.flake.home.packages.lang-python];

    programs.lazyvim.extras.lang.python.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.editor.lang.python];
}
