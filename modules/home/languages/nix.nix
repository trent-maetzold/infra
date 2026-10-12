{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.nix;
in {
  config = lib.mkMerge [
    {languages.nix.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.packages = lib.mkAfter (with pkgs; [
        alejandra
        nil
        statix
      ]);
      programs.lazyvim.extras.lang.nix.enable = lib.mkDefault true;
    })
  ];

  options.languages.nix.enable = lib.mkEnableOption "nix language support";
}
