{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos.home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
  flake.nixosModules.default.imports = [config.flake.modules.nixos.home-manager];
}
