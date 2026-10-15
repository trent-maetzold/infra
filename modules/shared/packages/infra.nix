{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [colmena nixos-anywhere rage];
  };
in {
  # Features
  features.home.packages.infra = out;

  # Home Manager Modules
  flake.homeModules.infra.imports = [config.features.home.packages.infra];
}
