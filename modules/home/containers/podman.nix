{config, ...}: let
  out = {pkgs, ...}: {
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
in {
  # Features
  features.home.containers.podman = out;

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.containers.podman];
}
