{config, ...}: {
  flake.modules.homeManager.languages-sql = {...}: {
    programs.lazyvim.extras.lang.sql.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.languages-sql];
}
