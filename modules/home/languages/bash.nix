{config, ...}: {
  flake.home.languages.bash = {pkgs, ...}: {
    home.packages = with pkgs; [bash-language-server bashdb shellcheck shfmt];
  };
  flake.homeModules.default.imports = [config.flake.home.languages.bash];
}
