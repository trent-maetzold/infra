{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.lua.enable = lib.mkEnableOption "Lua language support (edit, run, debug)";

  config = lib.mkMerge [
    {languages.lua.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.lua.enable {
      home.packages = lib.mkDefault (with pkgs; [
        lua-language-server
        stylua
      ]);
    })
  ];
}
