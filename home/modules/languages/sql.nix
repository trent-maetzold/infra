{
  config,
  lib,
  ...
}: let
  cfg = config.languages.sql;
in {
  config = lib.mkMerge [
    {languages.sql.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      programs.lazyvim.extras.lang.sql.enable = lib.mkDefault true;
    })
  ];

  options.languages.sql.enable = lib.mkEnableOption "sql language support";
}
