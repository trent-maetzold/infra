{
  config,
  home-manager,
  ...
}: let
  out = {
    imports = [home-manager.nixosModules.home-manager];

    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
in {
  # Modules
  my.modules.base.home-manager.nixos = out;

  # NixOS Modules
  flake.nixosModules.default.imports = [config.my.modules.base.home-manager.nixos];
}
