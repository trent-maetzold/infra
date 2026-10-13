{config, ...}: {
  flake.home.languages.docker = {pkgs, ...}: {
    home.packages = with pkgs; [docker-compose-language-service dockerfile-language-server];
    programs.lazyvim.extras.lang.docker.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.languages.docker];
}
