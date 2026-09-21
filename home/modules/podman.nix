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
      programs.zsh.oh-my-zsh.plugins = ["podman"];
      services.podman.extraPackages = lib.mkAfter (with pkgs; [podman-compose]);
    })
  ];
}
