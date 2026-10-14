{
  flake.home.packages.podman = {pkgs, ...}: {
    home.packages = with pkgs; [fuse-overlayfs podman-compose slirp4netns];
  };
}
