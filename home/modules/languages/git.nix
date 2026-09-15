{
  config,
  lib,
  ...
}: {
  options.languages.git.enable = lib.mkEnableOption "gitconfig/hunk editing support in editors";

  config = lib.mkMerge [
    {languages.git.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.git.enable {
      programs.lazyvim.extras.lang.git.enable = lib.mkDefault true;
    })
  ];
}
