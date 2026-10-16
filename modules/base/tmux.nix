{config, ...}: let
  out = {
    programs.tmux.enable = true;
  };
in {
  # Modules
  my.modules.base.tmux.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.base.tmux.home];
}
