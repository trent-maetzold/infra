{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.languages.docker;
in {
  config = lib.mkMerge [
    {languages.docker.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.packages = lib.mkAfter (with pkgs; [
        docker-compose-language-service
        dockerfile-language-server
      ]);
      programs.lazyvim.extras.lang.docker.enable = lib.mkDefault true;
    })
  ];

  options.languages.docker.enable = lib.mkEnableOption "docker language support";
}
