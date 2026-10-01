{lib, ...}: {
  asgard.enable = lib.mkDefault true;
  programs = {
    git.enable = lib.mkDefault true;
    ssh.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
  };
}
