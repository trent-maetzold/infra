{config, ...}: let
  inherit (config) features flake;
  out = {config, ...}: {
    imports = [features.home.packages.admin];

    home = {
      homeDirectory = "/home/${config.home.username}";
      sessionPath = ["${config.home.homeDirectory}/.local/bin"];
    };
  };
in {
  # Features
  features.home.base.core = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.base.core];
}
