{config, ...}: {
  flake.home.editor.lang.go = {
    imports = [config.flake.home.packages.lang-go];

    programs.lazyvim.extras.lang.go.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.editor.lang.go];
}
