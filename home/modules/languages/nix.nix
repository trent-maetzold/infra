{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.nix.enable = lib.mkEnableOption "Nix language support (edit, evaluate, format)";

  config = lib.mkMerge [
    {languages.nix.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.nix.enable {
      programs.lazyvim.extras.lang.nix.enable = lib.mkDefault true;
      home.packages = lib.mkDefault (with pkgs; [
        nil
        alejandra
        statix
      ]);
    })
  ];
}
