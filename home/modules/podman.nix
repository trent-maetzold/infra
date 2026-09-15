{
  lib,
  pkgs,
  ...
}: {
  services.podman.enable = lib.mkDefault true;
  home.packages = lib.mkAfter (with pkgs; [
    podman-compose
    slirp4netns
    fuse-overlayfs
  ]);
}
