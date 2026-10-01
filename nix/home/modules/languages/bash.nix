{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.bash;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs; [
      bash-language-server
      bashdb
      shellcheck
      shfmt
    ]);
  };

  options.languages.bash.enable = lib.mkEnableOption "bash language support";
}
