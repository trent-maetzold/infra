{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.toml;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter [pkgs.taplo];
    programs.lazyvim.extras.lang.toml.enable = lib.mkDefault true;
  };

  options.languages.toml.enable = lib.mkEnableOption "toml language support";
}
