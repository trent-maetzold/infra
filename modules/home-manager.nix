{
  config,
  lib,
  lazyvim,
  ...
}: let
  cfg = config.home-manager;
in {
  config = lib.mkMerge [
    {home-manager.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home-manager = {
        backupFileExtension = lib.mkDefault "backup";
        extraSpecialArgs = {inherit lazyvim;};
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
      };
    })
  ];

  options.home-manager.enable = lib.mkEnableOption "the tm home profile (account + home-manager wiring)";
}
