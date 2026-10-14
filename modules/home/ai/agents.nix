{config, ...}: {
  flake.home.ai.agents = {
    imports = [config.flake.home.packages.ai];

    home.file.".agents" = {
      source = ./config;
      recursive = true;
    };
  };
  flake.homeModules.default.imports = [config.flake.home.ai.agents];
}
