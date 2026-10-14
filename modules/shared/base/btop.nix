{config, ...}: {
  flake.nixos.base.btop = {
    imports = [config.flake.nixos.packages.btop];
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
