{config, ...}: {
  flake.modules.homeManager.languages-git = {...}: {
    programs.lazyvim.extras.lang.git.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.languages-git];
}
