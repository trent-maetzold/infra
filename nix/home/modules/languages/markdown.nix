{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.markdown;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs; [
      markdown-toc
      markdownlint-cli2
      marksman
    ]);
    programs.lazyvim.extras.lang.markdown.enable = lib.mkDefault true;
  };

  options.languages.markdown.enable = lib.mkEnableOption "markdown language support";
}
