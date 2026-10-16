{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [bun nodejs pnpm prettier vscode-extensions.ms-vscode.js-debug vtsls];
    programs.lazyvim.extras.lang.typescript.enable = true;
  };
in {
  # Modules
  my.modules.lang.js.home = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.lang.js.home];
}
