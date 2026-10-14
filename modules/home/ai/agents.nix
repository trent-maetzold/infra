{config, ...}: let
  out = {
    imports = [config.features.home.packages.ai];

    home.file.".agents" = {
      source = ./config;
      recursive = true;
    };
  };
in {
  # Features
  features.home.ai.agents = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.ai.agents];
}
