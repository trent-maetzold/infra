{config, ...}: {
  flake.home.languages.go = {pkgs, ...}: {
    home.packages = with pkgs; [delve go gopls gotools];
    programs.lazyvim.extras.lang.go.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.languages.go];
}
