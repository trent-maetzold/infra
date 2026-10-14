{
  flake.home.packages.lang-core = {pkgs, ...}: {
    home.packages = with pkgs; [alejandra bash-language-server docker-compose-language-service dockerfile-language-server markdown-toc markdownlint-cli2 marksman nil prettier shellcheck shfmt statix taplo vscode-langservers-extracted yaml-language-server];
  };
}
