{config, ...}: {
  flake.home.editor.lang.js = {
    imports = [config.flake.home.packages.lang-js];

    programs.lazyvim.extras.lang.typescript.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.editor.lang.js];
}
