{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.json;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter [pkgs.vscode-langservers-extracted];
    programs.lazyvim.extras.lang.json.enable = lib.mkDefault true;
  };

  options.languages.json.enable = lib.mkEnableOption "json language support";
}
