{config, ...}: {
  flake.home.containers.podman = {
    imports = [config.flake.home.packages.podman];

    programs = {
      lazydocker.enable = true;
      zsh.oh-my-zsh.plugins = ["podman"];
    };
    services.podman.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.containers.podman];
}
