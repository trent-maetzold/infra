{config, ...}: {
  flake.home.languages.markdown = {pkgs, ...}: {
    home.packages = with pkgs; [markdown-toc markdownlint-cli2 marksman];
    programs.lazyvim.extras.lang.markdown.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.languages.markdown];
}
