{
  config,
  inputs,
  ...
}: {
  flake.nixos.base.home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
  flake.nixosModules.default.imports = [config.flake.nixos.base.home-manager];
}
