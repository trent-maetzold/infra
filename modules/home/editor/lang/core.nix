{config, ...}: {
  flake.home.editor.lang.core = {
    imports = [config.flake.home.packages.lang-core];

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
