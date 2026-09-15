{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.go.enable = lib.mkEnableOption "Go language support (edit, build, run, debug)";

  config = lib.mkMerge [
    {languages.go.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.go.enable {
      programs.lazyvim.extras.lang.go.enable = lib.mkDefault true;
      home.packages = lib.mkDefault (with pkgs; [
        go
        gopls
        gotools
        delve
      ]);
    })
  ];
}
