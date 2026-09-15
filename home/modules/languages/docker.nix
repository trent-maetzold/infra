{
  config,
  lib,
  pkgs,
  ...
}: {
  options.languages.docker.enable = lib.mkEnableOption "Dockerfile/compose language support";

  config = lib.mkMerge [
    {languages.docker.enable = lib.mkDefault true;}
    (lib.mkIf config.languages.docker.enable {
      programs.lazyvim.extras.lang.docker.enable = lib.mkDefault true;
      home.packages = lib.mkDefault (with pkgs; [
        dockerfile-language-server
        docker-compose-language-service
      ]);
    })
  ];
}
