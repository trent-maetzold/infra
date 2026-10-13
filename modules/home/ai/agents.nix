{config, ...}: {
  flake.home.ai.agents = {
    home.file.".agents" = {
      source = ./config;
      recursive = true;
    };
  };
  flake.homeModules.default.imports = [config.flake.home.ai.agents];
}
