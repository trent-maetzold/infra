{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.toml.enable = lib.mkEnableOption "TOML language support";

  config = lib.mkMerge [
    {languages.toml.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.toml.enable {
      programs.lazyvim.extras.lang.toml.enable = lib.mkDefault true;
      home.packages = lib.mkAfter [pkgs.taplo];
    })
  ];
}
