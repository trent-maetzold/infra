let
  out = {pkgs, ...}: {
    home.packages = with pkgs; [harlequin tredis];
  };
in {
  # Features
  features.home.packages.data = out;
}
