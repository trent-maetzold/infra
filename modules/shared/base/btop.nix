{config, ...}: {
  flake.nixos.base.btop = {pkgs, ...}: {
    environment.systemPackages = [pkgs.btop];
  };
  flake.home.base.btop = {
    programs.btop = {
      enable = true;
      settings.vim_keys = true;
    };
  };
  flake.nixosModules.default.imports = [config.flake.nixos.base.btop];
  flake.homeModules.default.imports = [config.flake.home.base.btop];
}
