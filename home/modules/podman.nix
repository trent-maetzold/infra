{
  lib,
  pkgs,
  ...
}: {
  services.podman.enable = lib.mkDefault true;
  home.packages = lib.mkDefault (with pkgs; [
    podman-compose
    slirp4netns
    fuse-overlayfs
  ]);
}
