{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.markdown.enable = lib.mkEnableOption "Markdown language support (edit, lint)";

  config = lib.mkMerge [
    {languages.markdown.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.markdown.enable {
      programs.lazyvim.extras.lang.markdown.enable = lib.mkDefault true;
      home.packages = lib.mkDefault (with pkgs; [
        marksman
        markdown-toc
        markdownlint-cli2
      ]);
    })
  ];
}
