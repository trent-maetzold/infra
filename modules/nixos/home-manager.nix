{config, ...}: {
  flake.nixosModules.home-manager = {
    config,
    lib,
    ...
  }: let
    cfg = config.home-manager;
  in {
    config = lib.mkMerge [
      {home-manager.enable = lib.mkDefault true;}
      (lib.mkIf cfg.enable {
        home-manager = {
          backupFileExtension = lib.mkDefault "backup";
          useGlobalPkgs = lib.mkDefault true;
          useUserPackages = lib.mkDefault true;
        };
      })
    ];

    options.home-manager.enable = lib.mkEnableOption "asgard's home-manager wiring";
  };
  flake.nixosModules.default.imports = [config.flake.nixosModules.home-manager];
}
