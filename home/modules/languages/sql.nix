{
  config,
  lib,
  ...
}: {
  options.languages.sql.enable = lib.mkEnableOption "SQL language support";

  config = lib.mkMerge [
    {languages.sql.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.sql.enable {
      programs.lazyvim.extras.lang.sql.enable = lib.mkDefault true;
    })
  ];
}
