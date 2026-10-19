{config, ...}: let
  out = {
    programs.tmux.enable = true;
  };
in {
  # Features
  features.home.base.tmux = out;

  # Home Manager Modules
  flake.homeModules = {
    default.imports = [config.features.home.base.tmux];
    server.imports = [config.features.home.base.tmux];
  };
}
