{
  flake.home.packages.data = {pkgs, ...}: {
    home.packages = with pkgs; [harlequin tredis];
  };
}
