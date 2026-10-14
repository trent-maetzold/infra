{config, ...}: let
  inherit (config) flake;
in {
  flake.home.base.core = {config, ...}: {
    imports = [flake.home.packages.admin];

    home = {
      homeDirectory = "/home/${config.home.username}";
      sessionPath = ["${config.home.homeDirectory}/.local/bin"];
    };
  };
  flake.homeModules.default.imports = [config.flake.home.base.core];
}
