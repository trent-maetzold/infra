{config, ...}: let
  packages = pkgs: with pkgs; [curl gcc git gnumake just openssh openssl pkg-config tree unzip wget];
  nixos = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
  home = {pkgs, ...}: {home.packages = packages pkgs;};
in {
  # Features
  features.nixos.packages.admin = nixos;
  features.home.packages.admin = home;

  # NixOS Modules
  flake.nixosModules.default.imports = [config.features.nixos.packages.admin];

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.packages.admin];
}
