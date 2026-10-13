{config, ...}: {
  flake.home.languages.git = {...}: {
    programs.lazyvim.extras.lang.git.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.languages.git];
}
