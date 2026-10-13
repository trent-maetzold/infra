{config, ...}: {
  flake.home.languages.toml = {pkgs, ...}: {
    home.packages = with pkgs; [taplo];
    programs.lazyvim.extras.lang.toml.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.languages.toml];
}
