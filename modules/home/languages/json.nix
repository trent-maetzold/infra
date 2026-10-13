{config, ...}: {
  flake.home.languages.json = {pkgs, ...}: {
    home.packages = with pkgs; [vscode-langservers-extracted];
    programs.lazyvim.extras.lang.json.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.languages.json];
}
