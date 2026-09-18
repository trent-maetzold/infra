{
  config,
  lib,
  pkgs,
  lazyvim,
  ...
}: {
  imports = [
    ./agents
    ./languages
    ./neovim
    ./distrobox.nix
    ./git.nix
    ./podman.nix
    ./shell.nix
    ./ssh.nix
    lazyvim.homeManagerModules.default
  ];

  config = {
    home = {
      homeDirectory = lib.mkDefault "/home/${config.home.username}";
      sessionPath = ["${config.home.homeDirectory}/.local/bin"];
      shellAliases.ld = lib.mkDefault "lazydocker";
      packages = lib.mkAfter (with pkgs; [
        jq
        just
        tree
      ]);
    };
    programs = {
      btop = {
        enable = lib.mkDefault true;
        settings = {
          vim_keys = lib.mkDefault true;
        };
      };
      lazydocker.enable = lib.mkDefault true;
      nh.enable = lib.mkDefault true;
    };
  };
}
