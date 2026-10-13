{config, ...}: {
  flake.home.containers.podman = {pkgs, ...}: {
    home.packages = with pkgs; [
      fuse-overlayfs
      podman-compose
      slirp4netns
    ];
    programs = {
      lazydocker.enable = true;
      zsh.oh-my-zsh.plugins = ["podman"];
    };
    services.podman.enable = true;
  };
  flake.homeModules.default.imports = [config.flake.home.containers.podman];
}
