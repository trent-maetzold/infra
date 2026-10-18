{
  config,
  home-manager,
  ...
}: let
  out = {
    imports = [home-manager.nixosModules.home-manager];

    home-manager = {
      backupFileExtension = "backup";
      sharedModules = [config.features.home.base.state-version];
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
in {
  # Features
  features.nixos.base.home-manager = out;

  # NixOS Modules
  flake.nixosModules.default.imports = [config.features.nixos.base.home-manager];
}
