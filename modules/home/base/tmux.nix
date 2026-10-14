{config, ...}: {
  flake.home.base.tmux = {
    programs.tmux.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.base.tmux];
}
