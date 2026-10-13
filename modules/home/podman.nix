{config, ...}: {
  flake.modules.homeManager.podman = {pkgs, ...}: {
    home.packages = [pkgs.podman-compose];
    programs = {
      lazydocker.enable = true;
      zsh.oh-my-zsh.plugins = ["podman"];
    };
    services.podman.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.modules.homeManager.podman];
}
