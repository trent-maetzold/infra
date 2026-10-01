{
  config,
  lib,
  ...
}: let
  cfg = config.home-manager;
in {
  config = lib.mkIf cfg.enable {
    home-manager = {
      backupFileExtension = lib.mkDefault "backup";
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
    };
  };

  options.home-manager.enable = lib.mkEnableOption "Home Manager defaults";
}
