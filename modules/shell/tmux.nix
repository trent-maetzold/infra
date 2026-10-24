# tmux.
{config, ...}: let
  modules.homeManager = {
    programs.tmux.enable = true;
  };
in {
  # Flake Modules
  flake.modules.homeManager.tmux = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.tmux];
  flake.homeModules.server.imports = [config.flake.modules.homeManager.tmux];
}
