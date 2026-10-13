{config, ...}: {
  flake.modules.homeManager.languages-bash = {pkgs, ...}: {
    home.packages = with pkgs; [bash-language-server bashdb shellcheck shfmt];
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.languages-bash];
}
