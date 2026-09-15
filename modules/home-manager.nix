{
  config,
  lib,
  lazyvim,
  ...
}: {
  options.home-manager.enable = lib.mkEnableOption "the tm home profile (account + home-manager wiring)";

  config = lib.mkIf config.home-manager.enable {
    home-manager = {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      backupFileExtension = lib.mkDefault "backup";
      extraSpecialArgs = lib.mkDefault {inherit lazyvim;};
    };
  };
}
