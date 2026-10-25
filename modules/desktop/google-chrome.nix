# Google Chrome; family hosts allow its unfree licence, users opt in.
{config, ...}: let
  modules.nixos.nixpkgs.config.allowUnfreePackages = ["google-chrome"];

  modules.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.google-chrome];
  };
in {
  # Flake Modules
  flake.modules.nixos.google-chrome = modules.nixos;
  flake.modules.homeManager.google-chrome = modules.homeManager;

  # NixOS Configuration Modules
  flake.nixosModules.family.imports = [config.flake.modules.nixos.google-chrome];
}
