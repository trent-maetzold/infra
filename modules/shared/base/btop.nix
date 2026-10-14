{config, ...}: let
  nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.btop];
  };
  home = {
    programs.btop = {
      enable = true;
      settings.vim_keys = true;
    };
  };
in {
  # Features
  features.nixos.base.btop = nixos;
  features.home.base.btop = home;

  # NixOS Modules
  flake.nixosModules.default.imports = [config.features.nixos.base.btop];

  # Home Manager Modules
  flake.homeModules.default.imports = [config.features.home.base.btop];
}
