# Node, bun and pnpm with the TypeScript LSP.
{config, ...}: let
  modules.home = {pkgs, ...}: {
    home.packages = with pkgs; [bun nodejs pnpm prettier vscode-extensions.ms-vscode.js-debug vtsls];
    programs.lazyvim.extras.lang.typescript.enable = true;
  };
in {
  # Flake Modules
  flake.modules.homeManager.lang-js = modules.home;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.lang-js];
}
