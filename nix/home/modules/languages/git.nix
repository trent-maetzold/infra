{
  config,
  lib,
  ...
}: let
  cfg = config.languages.git;
in {
  config = lib.mkIf cfg.enable {
    programs.lazyvim.extras.lang.git.enable = lib.mkDefault true;
  };

  options.languages.git.enable = lib.mkEnableOption "git language support";
}
