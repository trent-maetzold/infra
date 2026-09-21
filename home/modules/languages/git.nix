{
  config,
  lib,
  ...
}: let
  cfg = config.languages.git;
in {
  config = lib.mkMerge [
    {languages.git.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      programs.lazyvim.extras.lang.git.enable = lib.mkDefault true;
    })
  ];

  options.languages.git.enable = lib.mkEnableOption "gitconfig/hunk editing support in editors";
}
