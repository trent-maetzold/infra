{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.yaml;
in {
  config = lib.mkMerge [
    {languages.yaml.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.packages = lib.mkAfter [pkgs.yaml-language-server];
      programs.lazyvim.extras.lang.yaml.enable = lib.mkDefault true;
    })
  ];

  options.languages.yaml.enable = lib.mkEnableOption "yaml language support";
}
