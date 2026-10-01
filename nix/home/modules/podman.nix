{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.podman;
in {
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkAfter (with pkgs; [podman-compose]);
    programs = {
      lazydocker.enable = lib.mkDefault true;
      zsh.oh-my-zsh.plugins = lib.mkAfter ["podman"];
    };
  };
}
