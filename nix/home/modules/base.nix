{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.asgard;
in {
  config = lib.mkIf cfg.enable {
    home = {
      homeDirectory = lib.mkDefault "/home/${config.home.username}";
      packages = lib.mkAfter (with pkgs; [
        harlequin
        just
        tree
        tredis
      ]);
      sessionPath = lib.mkAfter ["${config.home.homeDirectory}/.local/bin"];
      shellAliases.ld = lib.mkDefault "lazydocker";
    };
    programs = {
      btop = {
        enable = lib.mkDefault true;
        settings.vim_keys = lib.mkDefault true;
      };
      nh.enable = lib.mkDefault true;
    };
  };

  options.asgard.enable = lib.mkEnableOption "base Home Manager defaults";
}
