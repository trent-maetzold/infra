{config, ...}: {
  flake.modules.homeManager.languages-lua = {pkgs, ...}: {
    home.packages = with pkgs; [lua-language-server stylua];
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.languages-lua];
}
