{config, ...}: {
  flake.home.base.core = {config, ...}: {
    home = {
      homeDirectory = "/home/${config.home.username}";
      sessionPath = ["${config.home.homeDirectory}/.local/bin"];
    };
  };
  flake.homeModules.default.imports = [config.flake.home.base.core];
}
