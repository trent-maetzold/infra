{config, ...}: {
  flake.home.editor.lang.core = {pkgs, ...}: {
    home.packages = with pkgs; [
      alejandra
      bash-language-server
      docker-compose-language-service
      dockerfile-language-server
      markdown-toc
      markdownlint-cli2
      marksman
      nil
      prettier
      shellcheck
      shfmt
      statix
      taplo
      vscode-langservers-extracted
      yaml-language-server
    ];

    programs.lazyvim.extras.lang = {
      docker.enable = true;
      git.enable = true;
      json.enable = true;
      markdown.enable = true;
      nix.enable = true;
      sql.enable = true;
      toml.enable = true;
      yaml.enable = true;
    };
  };
  flake.homeModules.default.imports = [config.flake.home.editor.lang.core];
}
