{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.markdown;
in {
  config = lib.mkMerge [
    {languages.markdown.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.packages = lib.mkAfter (with pkgs; [
        markdown-toc
        markdownlint-cli2
        marksman
      ]);
      programs.lazyvim.extras.lang.markdown.enable = lib.mkDefault true;
    })
  ];

  options.languages.markdown.enable = lib.mkEnableOption "Markdown language support (edit, lint)";
}
