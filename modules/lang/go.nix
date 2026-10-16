{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [delve go gopls gotools];
    programs.lazyvim.extras.lang.go.enable = true;
  };
in {
  # Modules
  my.modules.lang.go.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.lang.go.home];
}
