# btop with vim keys.
{config, ...}: let
  modules.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.btop];
  };

  modules.home = {
    programs.btop = {
      enable = true;
      settings.vim_keys = true;
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.btop = modules.nixos;
  flake.modules.homeManager.btop = modules.home;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.btop];

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.btop];
  flake.homeModules.server.imports = [config.flake.modules.homeManager.btop];
}
