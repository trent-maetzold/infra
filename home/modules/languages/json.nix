{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.json.enable = lib.mkEnableOption "JSON language support";

  config = lib.mkMerge [
    {languages.json.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.json.enable {
      programs.lazyvim.extras.lang.json.enable = lib.mkDefault true;
      home.packages = lib.mkAfter [pkgs.vscode-langservers-extracted];
    })
  ];
}
