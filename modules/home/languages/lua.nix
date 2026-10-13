{config, ...}: {
  flake.home.languages.lua = {pkgs, ...}: {
    home.packages = with pkgs; [lua-language-server stylua];
  };
  flake.homeModules.default.imports = [config.flake.home.languages.lua];
}
