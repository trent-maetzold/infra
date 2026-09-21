{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.bash;
in {
  config = lib.mkMerge [
    {languages.bash.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.packages = lib.mkAfter (with pkgs; [
        bash-language-server
        bashdb
        shellcheck
        shfmt
      ]);
    })
  ];

  options.languages.bash.enable = lib.mkEnableOption "Bash/shell language support (edit, lint, debug)";
}
