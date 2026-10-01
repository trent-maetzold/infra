{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.typescript;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs; [
      bun
      nodejs
      pnpm
      prettier
      typescript-language-server
      vscode-extensions.ms-vscode.js-debug
      vtsls
    ]);
    programs.lazyvim.extras.lang.typescript.enable = lib.mkDefault true;
  };

  options.languages.typescript.enable = lib.mkEnableOption "typescript language support";
}
