{config, ...}: let
  packages = pkgs: with pkgs; [ffmpeg];
in {
  flake.nixos.packages.media = {pkgs, ...}: {
    environment.systemPackages = packages pkgs;
  };
  flake.home.packages.media = {pkgs, ...}: {
    home.packages = packages pkgs;
  };
  flake.nixosModules.default.imports = [config.flake.nixos.packages.media];
  flake.homeModules.default.imports = [config.flake.home.packages.media];
}
