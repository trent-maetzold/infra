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
  # Modules
  my.modules.base.btop = {inherit home nixos;};

  # NixOS Modules
  flake.nixosModules.default.imports = [config.my.modules.base.btop.nixos];

  # Home Manager Modules
  flake.homeModules.default.imports = [config.my.modules.base.btop.home];
}
