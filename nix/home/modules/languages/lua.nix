{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.lua;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs; [
      lua-language-server
      stylua
    ]);
  };

  options.languages.lua.enable = lib.mkEnableOption "lua language support";
}
