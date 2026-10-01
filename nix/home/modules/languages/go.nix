{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.go;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs; [
      delve
      go
      gopls
      gotools
    ]);
    programs.lazyvim.extras.lang.go.enable = lib.mkDefault true;
  };

  options.languages.go.enable = lib.mkEnableOption "go language support";
}
