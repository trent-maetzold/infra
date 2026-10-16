{config, ...}: let
  packages = pkgs: with pkgs; [curl gcc git gnumake just openssh openssl pkg-config tree unzip wget];
  nixos = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
  home = {pkgs, ...}: {home.packages = packages pkgs;};
in {
  # Modules
  my.modules.packages.admin = {inherit home nixos;};

  # NixOS Modules
  flake.nixosModules.default.imports = [config.my.modules.packages.admin.nixos];

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.packages.admin.home];
}
