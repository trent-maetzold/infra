{
  flake.home.packages.lang-js = {pkgs, ...}: {
    home.packages = with pkgs; [bun nodejs pnpm prettier typescript-language-server vscode-extensions.ms-vscode.js-debug vtsls];
  };
}
