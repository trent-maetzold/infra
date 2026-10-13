{config, ...}: {
  flake.home.languages.sql = {...}: {
    programs.lazyvim.extras.lang.sql.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.languages.sql];
}
