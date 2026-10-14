{config, ...}: {
  flake.home.editor.lang.rust = {
    imports = [config.flake.home.packages.lang-rust];

    programs.lazyvim.extras.lang.rust.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.editor.lang.rust];
}
