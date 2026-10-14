{
  flake.home.packages.git = {pkgs, ...}: {
    home.packages = with pkgs; [forgejo-cli];
  };
}
