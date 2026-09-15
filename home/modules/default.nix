{
  config,
  lib,
  pkgs,
  lazyvim,
  ...
}: {
  imports = [
    ./agents
    ./distrobox.nix
    ./git.nix
    ./languages
    ./lazyvim.nix
    ./podman.nix
    ./shell.nix
    ./ssh.nix
    ./tmux.nix
    lazyvim.homeManagerModules.default
  ];

  config = {
    home = {
      homeDirectory = lib.mkDefault "/home/${config.home.username}";
      sessionPath = lib.mkDefault ["${config.home.homeDirectory}/.local/bin"];
      shellAliases.ld = lib.mkDefault "lazydocker";
      packages = lib.mkDefault (with pkgs; [
        jq
        just
        tree
      ]);
    };
    programs = {
      lazydocker.enable = lib.mkDefault true;
      nh.enable = lib.mkDefault true;
    };
  };
}
