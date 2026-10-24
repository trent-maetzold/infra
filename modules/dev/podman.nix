# Rootless Podman as `docker`, with podman-compose and lazydocker.
{config, ...}: let
  modules.home = {pkgs, ...}: {
    home.packages = with pkgs; [
      fuse-overlayfs
      podman-compose
      slirp4netns
      # For tools that shell out to `docker`, without the Docker API socket.
      (writeShellScriptBin "docker" ''exec ${podman}/bin/podman "$@"'')
    ];

    programs = {
      lazydocker.enable = true;
      zsh.oh-my-zsh.plugins = ["podman"];
    };

    services.podman.enable = true;
  };
in {
  # Flake Modules
  flake.modules.homeManager.podman = modules.home;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.podman];
}
