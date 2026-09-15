{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.yaml.enable = lib.mkEnableOption "YAML language support";

  config = lib.mkMerge [
    {languages.yaml.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.yaml.enable {
      programs.lazyvim.extras.lang.yaml.enable = lib.mkDefault true;
      home.packages = lib.mkAfter [pkgs.yaml-language-server];
    })
  ];
}
