{config, ...}: let
  packages = pkgs: with pkgs; [curl gcc git gnumake just openssh openssl pkg-config tree unzip wget];
in {
  flake.nixos.packages.admin = {pkgs, ...}: {
    environment.systemPackages = packages pkgs;
  };
  flake.home.packages.admin = {pkgs, ...}: {
    home.packages = packages pkgs;
  };
  flake.nixosModules.default.imports = [config.flake.nixos.packages.admin];
  flake.homeModules.default.imports = [config.flake.home.packages.admin];
}
