{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.bash.enable = lib.mkEnableOption "Bash/shell language support (edit, lint, debug)";

  config = lib.mkMerge [
    {languages.bash.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.bash.enable {
      home.packages = lib.mkAfter (with pkgs; [
        bash-language-server
        shellcheck
        shfmt
        bashdb
      ]);
    })
  ];
}
