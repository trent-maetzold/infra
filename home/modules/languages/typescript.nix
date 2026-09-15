{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.typescript.enable = lib.mkEnableOption "TypeScript/JavaScript language support (edit, build, run, debug)";

  config = lib.mkMerge [
    {languages.typescript.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.typescript.enable {
      programs.lazyvim.extras.lang.typescript.enable = lib.mkDefault true;
      home.packages = lib.mkAfter (with pkgs; [
        nodejs
        pnpm
        bun
        prettier
        vtsls
        typescript-language-server
        vscode-extensions.ms-vscode.js-debug
      ]);
    })
  ];
}
