{config, ...}: {
  flake.modules.homeManager.languages-yaml = {pkgs, ...}: {
    home.packages = with pkgs; [yaml-language-server];
    programs.lazyvim.extras.lang.yaml.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.languages-yaml];
}
