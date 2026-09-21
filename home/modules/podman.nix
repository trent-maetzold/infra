{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.podman;
in {
  config = lib.mkMerge [
    {services.podman.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home.packages = lib.mkAfter (with pkgs; [podman-compose]);
      programs.zsh.oh-my-zsh.plugins = lib.mkAfter ["podman"];
    })
  ];
}
