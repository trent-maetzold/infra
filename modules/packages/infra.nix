{config, ...}: let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [colmena nixos-anywhere rage];
  };
in {
  # Modules
  my.modules.packages.infra.home = out;

  # Home Manager Modules
  flake.homeModules.infra.imports = [config.my.modules.packages.infra.home];
}
