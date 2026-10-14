{config, ...}: {
  flake.home.lang.js = {pkgs, ...}: {
    home.packages = with pkgs; [bun nodejs pnpm prettier typescript-language-server vscode-extensions.ms-vscode.js-debug vtsls];
    programs.lazyvim.extras.lang.typescript.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.lang.js];
}
