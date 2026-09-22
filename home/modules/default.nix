{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.asgard;
in {
  imports = [
    ./agents
    ./languages
    ./neovim
    ./distrobox.nix
    ./git.nix
    ./podman.nix
    ./shell.nix
    ./ssh.nix
  ];

  config = lib.mkMerge [
    {asgard.enable = lib.mkDefault true;}
    (lib.mkIf cfg.enable {
      home = {
        homeDirectory = lib.mkDefault "/home/${config.home.username}";
        packages = lib.mkAfter (with pkgs; [
          harlequin
          jq
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
        lazydocker.enable = lib.mkDefault true;
        nh.enable = lib.mkDefault true;
      };
    })
  ];

  options.asgard.enable = lib.mkEnableOption "asgard's base home-manager defaults";
}
